#!/usr/bin/env lua

--
-- Copyright (C) 2022 Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- module
local act = require('act')
require('gpoll').set_poller(act)
local assert = assert
local error = error
local ipairs = ipairs
local upper = string.upper
local sleep = require('gpoll').sleep
local new_context = require('context').new
local update_date = require('net.http.date').update
local new_http_server = require('net.http.server').new
local exists = require('exists')
local signal = require('signal')
local loadfile = require('loadchunk').file
local log = require('reflex.log')
local fs = require('reflex.fs')
local readcfg = require('reflex.readcfg')
local new_reflex = require('reflex')
local new_response = require('reflex.response')
local new_request = require('reflex.request')
-- constants
local CFGFILE = 'config.lua'
local INITFILE = 'init.lua'
local OPTIONS = require('getopts')({
    name = 'reflex',
    summary = 'reflex - a simple web application framework',
    desc = [[run a web application server in execution context]],
}, {
    conf = {
        help = 'path to configuration file',
        type = 'string',
    },
    test = {
        help = 'test the configuration and exit',
        is_flag = true,
    },
}, ...)

--- fatal
--- @param op string
--- @param ... any
local function fatal(op, ...)
    error(log.format('fatal error in %q: ', op) .. log.format(...), 2)
end

--- handle_connection
--- @param cfg table
--- @param conn net.http.connection
--- @param reflex reflex
local function handle_connection(cfg, conn, reflex)
    act.atexit(function(...)
        conn:close()
    end)

    local response_as_json = cfg.response_as_json == true
    local debug = cfg.debug
    repeat
        local msg, err = conn:read_request()
        if not msg then
            if err then
                log.error(err)
            end
            return
        end

        local req = new_request(msg)
        local res = new_response(reflex, conn, req, response_as_json, debug)
        local content = msg.content
        local keepalive = reflex:serve(res, req)
        if keepalive and content then
            local _
            _, err = content:dispose()
            if err then
                log.error('failed to dispose unused request content: ', err)
                return
            end
        end
    until not keepalive
end

--- listen_and_serve
--- @param cfg table
--- @param reflex reflex
--- @param s net.http.server
local function listen_and_serve(cfg, reflex, s)
    local _, err = s:listen(cfg.listen.backlog)
    if err then
        fatal('listen_and_serve', err)
    end

    log.info('start server:', cfg.listen.addr)
    while true do
        local conn
        conn, err = s:accept()
        if not conn then
            log.warn('failed to accept: %s', err)
        else
            _, err = conn.sock:tcpnodelay(true)
            if err then
                log.alert('failed to set tcpnodlay flag: %s', err)
            else
                act.spawn(handle_connection, cfg, conn, reflex)
            end
        end
    end
end

--- sigwait
local function sigwait(...)
    -- wait a SIGINT
    assert(act.sigwait(nil, ...))
end

local function updater(ctx)
    while not ctx:is_done() do
        sleep(1000)
        update_date()
    end
end

--- start
--- @param cfg table
--- @param reflex reflex
local function start(cfg, reflex)
    local s, err = new_http_server(cfg.listen.addr, cfg.listen)
    if not s then
        fatal('listen_and_serve', err)
    end

    signal.blockall()
    local ctx, cancel = new_context()
    assert(act.spawn(listen_and_serve, cfg, reflex, s))
    assert(act.spawn(sigwait, signal.SIGINT, signal.SIGTERM))
    assert(act.spawn(updater, ctx))

    local stat = assert(act.await())
    cancel()
    s:close()
    if stat.error then
        log.error(stat.error)
    end

    log.info('done')
end

--- init
--- @param cfg table<string, any>
local function init(cfg)
    local pathname, err = fs.realpath(INITFILE)
    local fn

    if pathname then
        fn, err = loadfile(pathname)
    end

    if err then
        fatal('init', 'failed to load %q: %s', INITFILE, err)
    elseif fn then
        log.info('run %q', INITFILE)

        local ok
        ok, err = pcall(fn, cfg)
        if not ok then
            fatal('init', 'failed to evaluate %q: %s', INITFILE, err)
        end
    end
end

local function main(opts)
    -- load config.lua
    local cfg

    if opts.conf then
        cfg = readcfg(opts.conf)
    else
        local t, err = exists(CFGFILE)
        if t then
            if t ~= 'file' then
                fatal('loadcfg', 'failed to load %q:%q: not a file', CFGFILE, t)
            end
            cfg = readcfg(CFGFILE)
        elseif err then
            fatal('loadcfg', 'failed to load %q: %s', CFGFILE, err)
        else
            cfg = readcfg()
        end
    end

    -- create router by a document root files
    log.info('create a routing table from %q', cfg.document.rootdir)
    local reflex, routes = new_reflex(cfg)

    -- force template.precheck
    if opts.test then
        cfg.template.precheck = true
    end

    -- print routing table
    do
        local nroute = #routes
        local rtree = {}

        for i = 1, nroute do
            local v = routes[i]

            -- precheck templates
            if v.file and cfg.template.precheck and
                cfg.template.files[v.file.ext] then
                log.info('precheck template %q', v.file.rpath)
                local ok, err = reflex.renderer:add(v.file.rpath)
                if not ok then
                    log.error('invalid template %q: %s', v.file.rpath, err)
                    fatal('main', 'failed to precheck %q', v.file.rpath)
                end
            end

            -- print route
            local fmt = i < nroute and '├── ' or '└── '
            rtree[#rtree + 1] = log.format(fmt .. '%s %q', upper(v.method),
                                           v.rpath)

            -- print route handlers
            local nhandler = #v.handlers
            for j = 1, nhandler do
                local handler = v.handlers[j]
                fmt = (i < nroute and '│' or ' ') .. '       '
                if j < nhandler then
                    fmt = fmt .. '├── '
                else
                    fmt = fmt .. '└── '
                end
                rtree[#rtree + 1] = log.format(fmt .. '%d. %s %s', j,
                                               handler.method, handler.name)
            end
        end

        log.info('%q', cfg.document.rootdir)
        for _, line in ipairs(rtree) do
            log.info(line)
        end
    end

    -- run custom initializer
    init(cfg)
    if opts.test then
        return
    end
    start(cfg, reflex)
end

do
    local ok, err = act.run(main, OPTIONS)
    if not ok then
        if OPTIONS.test then
            log.error('TEST FAILURE')
        end
        log.error(err)
    elseif OPTIONS.test then
        log.info('TEST OK')
    end

    if not OPTIONS.test then
        log.info('exit')
    end
end


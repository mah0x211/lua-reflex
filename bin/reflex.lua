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
local xpcall = xpcall
local traceback = debug.traceback
local assert = assert
local error = error
local ipairs = ipairs
local upper = string.upper
local sleep = require('gpoll').sleep
local new_context = require('context').new
local update_date = require('net.http.date').update
local new_http_server = require('net.http.server').new
local signal = require('signal')
local log = require('reflex.log')
local getopts = require('reflex.getopts')
local fs = require('reflex.fs')
local readcfg = require('reflex.readcfg')
local new_reflex = require('reflex')
-- constants
local CFGFILE = 'config.lua'

--- fatal
--- @param op string
--- @param ... any
local function fatal(op, ...)
    error(log.format('fatal error in %q: ', op) .. log.format(...), 2)
end

--- handle_connection
--- @param conn net.http.connection
--- @param reflex reflex
local function handle_connection(conn, reflex)
    act.atexit(function()
        conn:close()
    end)

    repeat
        local req, err = conn:read_request()

        if not req then
            if err then
                log.error('failed to read request:', err)
            end
            return
        end

        local content = req.content
        local ok, keepalive = xpcall(reflex.serve, traceback, reflex, conn, req)
        if not ok then
            log.error('failed serve content: ', keepalive)
            return
        end

        if keepalive and content then
            local _
            _, err = content:dispose()
            if err then
                log.error('failed to dispose request content: ', err)
                return
            end
        end
    until keepalive == false
end

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
                act.spawn(handle_connection, conn, reflex)
            end
        end
    end
end

local function sigwait(...)
    -- wait a SIGINT
    assert(act.sigwait(nil, signal.SIGINT))
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
    assert(act.spawn(sigwait, signal.SIGINT))
    assert(act.spawn(updater, ctx))

    local stat = assert(act.await())
    cancel()
    s:close()
    if stat.error then
        log.error(stat.error)
    end

    log.info('done')
end

--- loadcfg
--- @return table<string, any> cfg
--- @return boolean loaded
local function loadcfg()
    log.info('load %q', CFGFILE)
    local apath, err = fs.realpath(CFGFILE)
    if err then
        fatal('loadcfg', 'failed to load %q: %s', CFGFILE, err)
    end
    return readcfg(apath)
end

local function main(opts)
    -- load config.lua
    local cfg = loadcfg()

    -- create required directories
    for _, v in ipairs({
        '/tmp',
        '/session',
        '/trash',
    }) do
        log.info('mkdir %q', v)
        assert(fs.mkdir(v))
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

    if opts.test then
        return
    end
    start(cfg, reflex)
end

do
    local opts = getopts(_G.arg, {
        ['--help'] = {
            help = true,
            desc = 'this help',
        },
        ['--test'] = {
            desc = 'test configuration and exit',
        },
    })
    local ok, err = act.run(main, opts)
    if not ok then
        if opts.test then
            log.error('TEST FAILURE')
        end
        log.error(err)
    elseif opts.test then
        log.info('TEST OK')
    end

    if not opts.test then
        log.info('exit')
    end
end


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
local pcall = pcall
local ipairs = ipairs
local pairs = pairs
local open = io.open
local format = string.format
local assert = require('assert')
local isa = require('isa')
local is_boolean = isa.boolean
local is_int = isa.int
local is_finite = isa.int
local is_string = isa.string
local is_table = isa.table
local setenv = require('setenv')
local new_tls_config = require('net.tls.config').new
local loadfile = require('loadchunk').file
local session = require('reflex.session')
local errorf = require('reflex.errorf')

local function checkopt(val, checkfn, defval, msg, ...)
    if val == nil then
        return defval
    elseif checkfn(val) then
        return val
    end
    errorf(3, msg, ...)
end

--- verify_session
--- @param cfg table
--- @return table cfg
local function verify_session(cfg)
    cfg = checkopt(cfg, is_table, {}, 'session must be table')
    cfg.name = checkopt(cfg.name, is_string, nil, 'session.name must be string')
    cfg.attr = checkopt(cfg.attr, is_table, {}, 'session.attr must be table')
    cfg.attr.path = checkopt(cfg.attr.path, is_string, nil,
                             'session.attr.path must be string')
    cfg.attr.maxage = checkopt(cfg.attr.maxage, is_int, nil,
                               'session.attr.maxage must be integer')
    cfg.attr.secure = checkopt(cfg.attr.secure, is_boolean, nil,
                               'session.attr.secure must be boolean')
    cfg.attr.httponly = checkopt(cfg.attr.httponly, is_boolean, nil,
                                 'session.attr.httponly must be boolean')
    cfg.attr.samesite = checkopt(cfg.attr.samesite, is_string, nil,
                                 'session.attr.httponly must be string')
    session.set_name(cfg.name)
    session.set_attr(cfg.attr)
    return cfg
end

--- verify_template
--- @param cfg table
--- @return table cfg
local function verify_template(cfg)
    cfg = checkopt(cfg, is_table, {}, 'template must be table')

    -- templates
    local files = {}
    cfg.files = checkopt(cfg.files, is_table, {
        '.html',
    }, 'document.template.files must be table')
    for i, v in ipairs(cfg.files) do
        local ext = checkopt(v, is_string, nil,
                             'template.files#%d must be string', i)
        files[ext] = true
    end
    cfg.files = files

    -- cache
    cfg.cache = checkopt(cfg.cache, is_boolean, false,
                         'template.cache must be boolean')
    -- precheck
    cfg.precheck = checkopt(cfg.precheck, is_boolean, false,
                            'template.precheck must be boolean')

    return cfg
end

--- verify_document
--- @param cfg table
--- @return table cfg
local function verify_document(cfg)
    cfg = checkopt(cfg, is_table, {}, 'document must be table')

    -- rootdir
    cfg.rootdir = checkopt(cfg.rootdir, is_string, 'html',
                           'document.rootdir must be string')
    -- follow_symlink
    cfg.follow_symlink = checkopt(cfg.follow_symlink, is_boolean, false,
                                  'document.follow_symlink must be boolean')

    -- mimetypes
    cfg.mimetypes = checkopt(cfg.mimetypes, is_table, nil,
                             'document.mimetypes must be table')

    -- cache
    cfg.cache = checkopt(cfg.cache, is_boolean, false,
                         'document.cache must be boolean')

    -- ignore
    cfg.ignore = checkopt(cfg.ignore, is_table, {},
                          'document.ignore must be table')
    for i, v in ipairs(cfg.ignore) do
        cfg.ignore[i] = checkopt(v, is_string, nil,
                                 'document.ignore#%d must be string', i)
    end

    -- no_ignore
    cfg.no_ignore = checkopt(cfg.no_ignore, is_table, nil,
                             'document.no_ignore must be table')
    for i, v in ipairs(cfg.no_ignore or {}) do
        cfg.no_ignore[i] = checkopt(v, is_string, nil,
                                    'document.no_ignore#%d must be string', i)
    end

    -- trim_extentions
    cfg.trim_extentions = checkopt(cfg.trim_extentions, is_table, {
        '.html',
        '.htm',
    }, 'document.trim_extentions must be table')
    for i, v in ipairs(cfg.trim_extentions) do
        cfg.trim_extentions[i] = checkopt(v, is_string, nil,
                                          'document.trim_extentions#%d must be string',
                                          i)
    end

    -- error_pages
    cfg.error_pages = checkopt(cfg.error_pages, is_table, {},
                               'document.error_pages must be table')
    for i, v in ipairs(cfg.error_pages) do
        cfg.error_pages[i] = checkopt(v, is_string, nil,
                                      'document.error_pages#%d must be string',
                                      i)
    end

    return cfg
end

--- verify_listen
--- @param cfg table
--- @return table cfg
local function verify_listen(cfg)
    cfg = checkopt(cfg, is_table, {}, 'listen must be table')

    -- check addr
    cfg.addr = checkopt(cfg.addr, is_string, '127.0.0.1:8080',
                        'listen.addr must be string')
    -- check reuseaddr
    cfg.reuseaddr = checkopt(cfg.reuseaddr, is_boolean, true,
                             'listen.reuseaddr must be boolean')
    -- check backlog
    cfg.backlog = checkopt(cfg.backlog, is_int, nil,
                           'listen.backlog must be integer')
    -- check cert files
    local key = checkopt(cfg.cert_key, is_string, nil,
                         'listen.cert_key must be string')
    local pem = checkopt(cfg.cert_pem, is_string, nil,
                         'listen.cert_pem must be string')
    local dhparams = checkopt(cfg.cert_dhparams, is_string, nil,
                              'listen.cert_dhparams must be string')
    if key and pem then
        local tlscfg = new_tls_config()
        local ok, err = tlscfg:set_keypair_file(pem, key)
        if not ok then
            error(format('failed to set tls keypair files: %s', err))
        elseif dhparams then
            local f
            f, err = open(dhparams, 'r')
            if not f then
                error(
                    format('failed to open dhparam file %q: %s', dhparams, err))
            end
            local s = f:read('*a')
            f:close()

            ok, err = tlscfg:set_dheparams(s)
            if not ok then
                error(format('failed to set tls dhparams %q: %s', dhparams, err))
            end
        end

        cfg.tlscfg = tlscfg
    end

    return cfg
end

--- verify_env
--- @param cfg table
--- @return table cfg
local function verify_env(cfg)
    cfg = checkopt(cfg, is_table, {}, 'env must be table')

    -- export environment variables
    for key, val in pairs(cfg) do
        checkopt(key, is_string, nil, 'key <%q> in env table must be string',
                 tostring(key))
        checkopt(val, function(v)
            if is_boolean(v) then
                val = '1'
                return true
            elseif is_finite(v) then
                val = tostring(val)
                return true
            end
            return is_string(v)
        end, nil, 'env.%s must be string, boolean or finite-number', key)
        cfg[key] = val
        assert(setenv(key, val, true))
    end

    return cfg
end

--- readconf
--- @return table<string, any> cfg
--- @return boolean loaded
local function readcfg(pathname)
    local rawcfg = {}
    local is_loaded = false

    if pathname then
        -- load config file
        local fn, err = loadfile(pathname, rawcfg)
        if err then
            errorf('failed to load %q: %s', pathname, err)
        end

        local ok, perr = pcall(fn)
        if not ok then
            errorf('failed to evaluate %q: %s', pathname, perr)
        end
        is_loaded = true
    end

    local cfg = {
        name = checkopt(rawcfg.name, is_string, 'unknown', 'name must be string'),
        version = checkopt(rawcfg.version, is_string, '0.0.0',
                           'version must be string'),
        debug = checkopt(rawcfg.debug, is_boolean, false,
                         'debug must be boolean'),
        response_as_json = checkopt(rawcfg.response_as_json, is_boolean, false,
                                    'response_as_json must be boolean'),
        env = verify_env(rawcfg.env),
        listen = verify_listen(rawcfg.listen),
        document = verify_document(rawcfg.document),
        template = verify_template(rawcfg.template),
        session = verify_session(rawcfg.session),
    }

    return cfg, is_loaded
end

return readcfg

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
local concat = table.concat
local ipairs = ipairs
local pairs = pairs
local sub = string.sub
local error = require('error')
local errorf = error.format
local assert = require('assert')
local exists = require('exists')
local fopen = require('io.fopen')
local isa = require('isa')
local is_boolean = isa.boolean
local is_int = isa.int
local is_finite = isa.int
local is_string = isa.string
local is_table = isa.table
local setenv = require('setenv')
local new_tls_config = require('net.tls.config').new
local loadfile = require('loadchunk').file
local log = require('reflex.log')
local session = require('reflex.session')
local fatalf = require('reflex.fatalf')

local function checkopt(val, checkfn, defval, msg, ...)
    if val == nil then
        return defval
    elseif checkfn(val) then
        return val
    end
    fatalf(3, msg, ...)
end

--- verify_session
--- @param cfg table
--- @return table cfg
local function verify_session(cfg)
    cfg = checkopt(cfg, is_table, {}, 'session must be table')
    cfg.name = checkopt(cfg.name, is_string, session.DEFAULT_NAME,
                        'session.name must be string')
    cfg.attr = checkopt(cfg.attr, is_table, {}, 'session.attr must be table')
    cfg.attr.path = checkopt(cfg.attr.path, is_string,
                             session.DEFAULT_PATH_ATTR,
                             'session.attr.path must be string')
    cfg.attr.maxage = checkopt(cfg.attr.maxage, is_int,
                               session.DEFAULT_MAXAGE_ATTR,
                               'session.attr.maxage must be integer')
    cfg.attr.secure = checkopt(cfg.attr.secure, is_boolean,
                               session.DEFAULT_SECURE_ATTR,
                               'session.attr.secure must be boolean')
    cfg.attr.httponly = checkopt(cfg.attr.httponly, is_boolean,
                                 session.DEFAULT_HTTPONLY_ATTR,
                                 'session.attr.httponly must be boolean')
    cfg.attr.samesite = checkopt(cfg.attr.samesite, is_string,
                                 session.DEFAULT_SAMESITE_ATTR,
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

    -- template environment file
    cfg.env = checkopt(cfg.env, is_string, nil, 'template.env must be string')
    if cfg.env then
        -- load file
        local fn, err = loadfile(cfg.env, _G)
        if err then
            fatalf('failed to evaluate template.env %q: %s', cfg.env, err)
        end

        local ok, res = pcall(fn)
        if not ok then
            fatalf('failed to evaluate template.env %q: %s', cfg.env, res)
        end

        cfg.env = checkopt(res, is_table, nil,
                           'template.env %q must return a table', cfg.env)
    end

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

    -- static
    cfg.static = checkopt(cfg.staticc, is_table, nil,
                          'document.static must be table')
    for i, v in ipairs(cfg.static or {}) do
        cfg.static[i] = checkopt(v, is_string, nil,
                                 'document.static#%d must be string', i)
    end

    -- ignore
    cfg.ignore = checkopt(cfg.ignore, is_table, nil,
                          'document.ignore must be table')
    for i, v in ipairs(cfg.ignore or {}) do
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
    for code, v in pairs(cfg.error_pages) do
        if not is_int(code) then
            fatalf('document.error_pages index key %q must be integer', code)
        end
        cfg.error_pages[code] = checkopt(v, is_string, nil,
                                         'document.error_pages#%d must be string',
                                         code)
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
            fatalf('failed to set tls keypair files: %s', err)
        elseif dhparams then
            local f
            f, err = fopen(dhparams, 'r')
            if not f then
                fatalf('failed to open dhparam file %q: %s', dhparams, err)
            end
            local s = f:read('*a')
            f:close()

            ok, err = tlscfg:set_dheparams(s)
            if not ok then
                fatalf('failed to set tls dhparams %q: %s', dhparams, err)
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

--- verify_log
--- @param cfg table
--- @param debug boolean
local function verify_log(cfg, debug)
    cfg = checkopt(cfg, is_table, {}, 'log must be table')

    -- check level
    local levels = {
        'fatal',
        'emerge',
        'alert',
        'crit',
        'error',
        'warn',
        'notice',
        'info',
        'debug',
    }
    local valid_lv = {}
    for _, lv in ipairs(levels) do
        valid_lv[lv] = true
    end
    local supported_levels = '"' .. concat(levels, '", "') .. '"'
    local level = checkopt(cfg.level, is_string, nil,
                           'log.level must be one of the following %s',
                           supported_levels)
    if level then
        if not valid_lv[level] then
            fatalf('unknown log.level %q: must be %s', level, supported_levels)
        elseif debug then
            log.warn('ignore log.level %q on debug mode')
        else
            log.setlevel(level)
        end
    end

    -- check filename
    local filename = checkopt(cfg.filename, is_string, nil,
                              'log.file must be string')
    if filename then
        local mode = 'w+'
        -- use append mode if filename has '+' suffix
        if sub(filename, #filename) == '+' then
            mode = 'a+'
            filename = sub(filename, 1, #filename - 1)
        end

        local f, err = fopen(filename, mode)
        if not f then
            fatalf('failed to open log.filename %q: %s', filename, err)
        end
        f:setvbuf('line')
        log.setoutput(f)
    end
end

local DEFAULT_CFGFILE = 'config.lua'

--- get_default_cfgfile
--- @return string? pathname
--- @return any err
local function get_default_cfgfile()
    local ftype, err = exists(DEFAULT_CFGFILE)
    if ftype then
        if ftype == 'file' then
            return DEFAULT_CFGFILE
        end
        return nil, errorf('%q is not a file: %s', DEFAULT_CFGFILE, ftype)
    end
    return nil, err
end

--- readconf
--- @param pathname string
--- @return table<string, any> cfg
--- @return boolean loaded
local function readcfg(pathname)
    local rawcfg = {}
    local is_loaded = false

    if not pathname then
        local err
        pathname, err = get_default_cfgfile()
        if err then
            fatalf('failed to load %q: %s', DEFAULT_CFGFILE, err)
        end
    end

    if pathname then
        -- load config file
        local fn, err = loadfile(pathname, rawcfg)
        if err then
            fatalf('failed to load %q: %s', pathname, err)
        end

        local ok, perr = pcall(fn)
        if not ok then
            fatalf('failed to evaluate %q: %s', pathname, perr)
        end
        is_loaded = true
    end

    local debug = checkopt(rawcfg.debug, is_boolean, false,
                           'debug must be boolean')
    if debug then
        log.setlevel('debug')
        log.setdebug(true)
        error.debug(true)
    end
    verify_log(rawcfg.log, debug)

    local cfg = {
        debug = debug,
        name = checkopt(rawcfg.name, is_string, 'unknown', 'name must be string'),
        version = checkopt(rawcfg.version, is_string, '0.0.0',
                           'version must be string'),
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

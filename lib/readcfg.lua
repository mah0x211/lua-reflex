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
local pairs = pairs
local assert = require('assert')
local isa = require('isa')
local is_table = isa.table
local setenv = require('setenv')
local loadfile = require('loadchunk').file
local session = require('reflex.session')
local errorf = require('reflex.errorf')

--- verify
--- @param cfg table
--- @return table
local function verify(cfg)
    assert.is_table(cfg)

    -- TODO: check the config format

    -- set default session config
    if cfg.session then
        if not is_table(cfg.session) then
            error('session must be table')
        end
        session.set_name(cfg.session.name)
        session.set_attr(cfg.session)
    end

    -- export environment variables
    if cfg.env then
        if not is_table(cfg.env) then
            error('env must be table')
        end
        for k, v in pairs(cfg.env) do
            assert(setenv(k, v, true))
        end
    end

    return cfg
end

--- readconf
--- @return table<string, any> cfg
--- @return boolean loaded
local function readcfg(pathname)
    local cfg = {
        name = 'unknown',
        version = '0.0.0',
        docroot = 'html',
    }

    -- return default config
    if not pathname then
        return verify(cfg), false
    end

    -- load config file
    local fn, err = loadfile(pathname, cfg)
    if err then
        errorf('failed to load %q: %s', pathname, err)
    end

    local ok
    ok, err = pcall(fn)
    if not ok then
        errorf('failed to evaluate %q: %s', pathname, err)
    end

    return verify(cfg), true
end

return readcfg

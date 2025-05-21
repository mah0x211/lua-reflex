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
local new_session_manager = require('session').new

--- session-cookie name
local DEFAULT_NAME = 'sid'
local DEFAULT_PATH_ATTR = '/'
local DEFAULT_MAXAGE_ATTR = 60 * 30
local DEFAULT_SECURE_ATTR = true
local DEFAULT_HTTPONLY_ATTR = true
local DEFAULT_SAMESITE_ATTR = 'lax'
local DEFAULT_COOKIE_CONFIG = {
    name = DEFAULT_NAME,
    domain = '',
    path = DEFAULT_PATH_ATTR,
    maxage = DEFAULT_MAXAGE_ATTR,
    secure = DEFAULT_SECURE_ATTR,
    httponly = DEFAULT_HTTPONLY_ATTR,
    samesite = DEFAULT_SAMESITE_ATTR,
}

local Manager = new_session_manager({
    cookie = DEFAULT_COOKIE_CONFIG,
})

--- @class session.store
--- @field get fun(self, key: string, ttl: integer?):(ok: boolean, err: any, timeout: boolean?)
--- @field set fun(self, key: string, val: any, ttl: integer?):(ok: boolean, err: any)
--- @field delete fun(self, key: string):(ok: boolean, err: any)
--- @field rename fun(self, key: string, newkey: string):(ok: boolean, err: any)
--- @field keys fun(self, callback: fun(key: string):(ok: boolean, err: any), ...):(ok: boolean, err: any)
--- @field evict fun(self, callback: fun(key: string):(ok: boolean, err: any), n: integer?, ...):(n: integer, err: any)

--- set_store
--- @param store session.store
local function set_store(store)
    assert(store ~= nil, 'store must not be nil')

    -- create new session.Manager with specified store
    local cookie = Manager.cookie
    Manager = new_session_manager({
        store = store,
    })
    Manager.cookie = cookie
end

--- set cookie configuration
--- @param cfg table?
local function set_cookie_config(cfg)
    assert(cfg == nil or type(cfg) == 'table', 'cfg must be nil or table')
    Manager.cookie:set_config(cfg or DEFAULT_COOKIE_CONFIG)
end

--- get cookie configuration
--- @return table
local function get_cookie_config()
    return Manager.cookie:get_config()
end

--- @class session.Session

--- create new session object
--- @return session.Session
local function new()
    return Manager:create()
end

--- restore session from cookie
--- @param sid string
--- @return session.Session? s
--- @return any err
--- @return boolean? timeout
local function restore(sid)
    assert(type(sid) == 'string', 'sid must be string')
    return Manager:fetch(sid)
end

return {
    set_store = set_store,
    get_cookie_config = get_cookie_config,
    set_cookie_config = set_cookie_config,
    restore = restore,
    new = new,
    -- export default config
    DEFAULT_NAME = DEFAULT_NAME,
    DEFAULT_PATH_ATTR = DEFAULT_PATH_ATTR,
    DEFAULT_MAXAGE_ATTR = DEFAULT_MAXAGE_ATTR,
    DEFAULT_SECURE_ATTR = DEFAULT_SECURE_ATTR,
    DEFAULT_HTTPONLY_ATTR = DEFAULT_HTTPONLY_ATTR,
    DEFAULT_SAMESITE_ATTR = DEFAULT_SAMESITE_ATTR,
}


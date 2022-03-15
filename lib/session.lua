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
require('reflex.global')
local is_finite = is_finite
local is_string = is_string
local is_table = is_table
local is_function = is_function
local find = string.find
local getmetatable = debug.getmetatable
local bake_cookie = require('cookie').bake
local uuid4str = require('ossp-uuid').gen4str

-- use reflex.cache module as default session store
local Store = require('reflex.cache').new()

--- set_store
--- @param store Cache
local function set_store(store)
    local t = store
    if not is_table(store) then
        local mt = getmetatable(store)
        t = is_table(mt) and is_table(mt.__index) and mt.__index or {}
    end

    if not is_function(t.set) or not is_function(t.get) or
        not is_function(t.del) then
        errorf(2, 'store must have %q, %q and %q methods', 'set', 'get', 'del')
    end

    Store = store
end

--- session-cookie name
local NAME = 'sid'

-- get_name
--- @return string name
local function get_name()
    return NAME
end

--- set_name
--- @param name string
local function set_name(name)
    if not is_string(name) or not find(name, '^[a-zA-Z0-9_]+$') then
        errorf(2, 'name must be string of %q', '^[a-zA-Z0-9_]+$')
    end
    NAME = name
end

--- session lifetime, default 30min
local MAXAGE = 60 * 30

--- get_maxage
--- @return integer maxage
local function get_maxage()
    return MAXAGE
end

--- set_maxage
--- @param maxage integer
local function set_maxage(maxage)
    if not is_finite(maxage) or maxage <= 0 then
        error('maxage must be integer greater than 0', 2)
    end
    MAXAGE = maxage
end

--- @class Session
--- @field id string
--- @field value table<string, any>
local Session = {}
Session.__index = Session

--- set
--- @param key string
--- @param val any
function Session:set(key, val)
    if not is_string(key) or find(key, '^%s+$') then
        error('key must be non-empty string', 2)
    end
    self.value[key] = val
end

--- get
--- @param key string
--- @return any val
function Session:get(key)
    if not is_string(key) then
        error('key must be string', 2)
    end
    return self.value[key]
end

--- save
--- @param attr table
--- @return boolean ok
--- @return string err
--- @return string cookie
function Session:save(attr)
    if attr == nil then
        attr = {}
    elseif not is_table(attr) then
        error('attr must be table', 2)
    end

    local ok, serr = Store:set(self.id, self.value, MAXAGE)
    if not ok then
        return false, serr
    end

    return true, nil, bake_cookie(NAME, self.id, {
        maxage = MAXAGE,
        domain = attr.domain,
        path = attr.path,
        secure = attr.secure == nil or attr.secure,
        httponly = attr.httponly == nil or attr.httponly,
        samesite = attr.samesite or 'lax',
    })
end

--- restore
--- @param id string
--- @return table value
--- @return string err
local function restore(id)
    if not is_string(id) then
        error('id must be string', 3)
    end

    local data, err = Store:get(id, true)
    if not data then
        return nil, err
    end

    return data
end

--- restore
--- @param id string
--- @return boolean ok
--- @return string err
function Session:restore(id)
    local value, err = restore(id)

    if value then
        self.id = id
        self.value = value
        return true
    end

    return false, err
end

--- destroy
--- @param attr table|nil
--- @return boolean ok
--- @return string err
--- @return string void_cookie
function Session:destroy(attr)
    if attr == nil then
        attr = {}
    elseif not is_table(attr) then
        error('attr must be table', 2)
    end

    local id, err = uuid4str()
    if not id then
        return false, err

    end

    local ok, serr = Store:del(self.id)
    if not ok then
        return false, serr
    end

    -- clear
    self.id = id
    self.value = {}
    return ok, nil, bake_cookie(NAME, 'void', {
        maxage = -60,
        domain = attr.domain,
        path = attr.path,
        secure = attr.secure == nil or attr.secure,
        httponly = attr.httponly == nil or attr.httponly,
        samesite = attr.samesite or 'lax',
    })
end

--- new
--- @param id string
--- @return Session ses
--- @return string err
local function new(id)
    if id ~= nil then
        local value, err = restore(id)
        if err then
            return nil, err
        elseif value then
            return setmetatable({
                id = id,
                value = value,
            }, Session)
        end
    elseif id ~= nil then
        error('id must be string', 2)
    end

    local newid, err = uuid4str()
    if not newid then
        return nil, err
    end

    return setmetatable({
        id = newid,
        value = {},
    }, Session)
end

return {
    new = new,
    set_store = set_store,
    get_name = get_name,
    set_name = set_name,
    get_maxage = get_maxage,
    set_maxage = set_maxage,
}


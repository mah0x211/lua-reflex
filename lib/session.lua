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
local find = string.find
local getmetatable = debug.getmetatable
local isa = require('isa')
local is_finite = isa.finite
local is_string = isa.string
local is_table = isa.table
local is_function = isa.Function
local new_cookie = require('cookie').new
local bake_cookie = require('cookie').bake
local uuid4str = require('ossp-uuid').gen4str
local errorf = require('reflex.errorf')

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
local DEFAULT_NAME = 'sid'
local NAME = DEFAULT_NAME

local DEFAULT_PATH_ATTR = '/'
local DEFAULT_MAXAGE_ATTR = 60 * 30
local DEFAULT_SECURE_ATTR = true
local DEFAULT_HTTPONLY_ATTR = true
local DEFAULT_SAMESITE_ATTR = 'lax'
local ATTR = {
    path = DEFAULT_PATH_ATTR,
    maxage = DEFAULT_MAXAGE_ATTR,
    secure = DEFAULT_SECURE_ATTR,
    httponly = DEFAULT_HTTPONLY_ATTR,
    samesite = DEFAULT_SAMESITE_ATTR,
}

--- bake_attributes
--- @param newattr table
--- @param attr table
--- @return table
local function bake_attributes(newattr, attr)
    for _, field in ipairs({
        'domain',
        'path',
        'maxage',
        'secure',
        'httponly',
        'samesite',
    }) do
        if newattr[field] == nil then
            local v = attr[field]
            if v == nil then
                v = ATTR[field]
            end
            newattr[field] = v
        end
    end

    return newattr
end

--- reset_defualt
local function reset_default()
    NAME = DEFAULT_NAME
    ATTR.domain = nil
    ATTR.path = DEFAULT_PATH_ATTR
    ATTR.maxage = DEFAULT_MAXAGE_ATTR
    ATTR.secure = DEFAULT_SECURE_ATTR
    ATTR.httponly = DEFAULT_HTTPONLY_ATTR
    ATTR.samesite = DEFAULT_SAMESITE_ATTR
end

--- set_default
--- @param name string
--- @param attr table<string, any>
local function set_default(name, attr)
    if name == nil then
        name = NAME
    end
    new_cookie(name, attr)

    if attr then
        if attr.maxage and (not is_finite(attr.maxage) or attr.maxage < 1) then
            error('attr.maxage must be integer greater than 0', 2)
        end

        ATTR.domain = attr.domain
        for _, k in ipairs({
            'maxage',
            'path',
            'secure',
            'httponly',
            'samesite',
        }) do
            local v = attr[k]
            if v ~= nil then
                ATTR[k] = v
            end
        end
    end
    NAME = name
end

--- get_defualt
--- @return string name
--- @return table attr
local function get_default()
    local defval = {}
    for k, v in pairs(ATTR) do
        defval[k] = v
    end
    return NAME, defval
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

--- delete
--- @param key string
--- @return any val
function Session:delete(key)
    if not is_string(key) then
        error('key must be string', 2)
    end

    local val = self.value[key]
    if val then
        self.value[key] = nil
    end

    return val
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

    local ok, serr = Store:set(self.id, self.value, ATTR.maxage)
    if not ok then
        return false, serr
    end

    return true, nil, bake_cookie(NAME, self.id, bake_attributes({}, attr))
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
    return ok, nil, bake_cookie(NAME, 'void', bake_attributes({
        maxage = -60,
    }, attr))
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
    reset_default = reset_default,
    set_default = set_default,
    get_default = get_default,
}


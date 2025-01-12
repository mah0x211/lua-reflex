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
local errorf = require('error').format
local isa = require('isa')
local is_finite = isa.finite
local is_boolean = isa.boolean
local is_string = isa.string
local is_table = isa.table
local is_function = isa.Function
local new_cookie = require('cookie').new
local bake_cookie = require('cookie').bake
local uuid4str = require('ossp-uuid').gen4str
local fatalf = require('error').fatalf

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

-- use cache.inmem module as default session store
local Store = require('cache.inmem').new(ATTR.maxage)

--- set_store
--- @param store cache
local function set_store(store)
    local t = store
    if not is_table(store) then
        local mt = getmetatable(store)
        t = is_table(mt) and is_table(mt.__index) and mt.__index or {}
    end

    if not is_function(t.set) or not is_function(t.get) or
        not is_function(t.delete) then
        fatalf(2, 'store must have %q, %q and %q methods', 'set', 'get',
               'delete')
    end

    Store = store
end

--- get_name
--- @return string name
local function get_name()
    return NAME
end

--- set_name
--- @param name string
local function set_name(name)
    if name == nil then
        name = DEFAULT_NAME
    end
    new_cookie(name, ATTR)
    NAME = name
end

--- get_attr
--- @return table attr
local function get_attr()
    local attr = {}
    for k, v in pairs(ATTR) do
        attr[k] = v
    end
    return attr
end

--- set_attr
--- @param attr table
local function set_attr(attr)
    if attr == nil then
        attr = {
            path = DEFAULT_PATH_ATTR,
            maxage = DEFAULT_MAXAGE_ATTR,
            secure = DEFAULT_SECURE_ATTR,
            httponly = DEFAULT_HTTPONLY_ATTR,
            samesite = DEFAULT_SAMESITE_ATTR,
        }
    end

    new_cookie(NAME, attr)
    if attr.maxage and (not is_finite(attr.maxage) or attr.maxage < 1) then
        fatalf('attr.maxage must be integer greater than 0')
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

--- restore
--- @param id string
--- @return table? value
--- @return any err
local function restore(id)
    if not is_string(id) then
        fatalf('id must be string')
    end

    local data, err = Store:get(id, ATTR.maxage)
    if err then
        return nil, errorf('failed to Store:get()', err)
    end

    return data
end

--- @class reflex.session
--- @field id string
--- @field value table<string, any>
local Session = {}

--- init
--- @param cookies table<string, string>
--- @param restore_only boolean
--- @return reflex.session? ses
--- @return any err
function Session:init(cookies, restore_only)
    if cookies ~= nil and not is_table(cookies) then
        fatalf('cookies must be table')
    elseif restore_only ~= nil and not is_boolean(restore_only) then
        fatalf('restore_only must be boolean')
    end

    if cookies then
        local id = cookies[get_name()]
        if id ~= nil then
            local value, err = restore(id)
            if err then
                return nil, errorf('failed to restore()', err)
            elseif value then
                self.id = id
                self.value = value
                return self
            end
        end
    end

    if restore_only then
        return nil
    end

    local newid, err = uuid4str()
    if not newid then
        return nil, errorf('failed to uuid4str()', err)
    end

    self.id = newid
    self.value = {}
    return self
end

--- restore
--- @param id string
--- @return boolean ok
--- @return any err
function Session:restore(id)
    local value, err = restore(id)
    if err then
        return false, errorf('failed to restore()', err)
    elseif not value then
        return false
    end

    self.id = id
    self.value = value
    return true
end

--- set
--- @param key string
--- @param val any
function Session:set(key, val)
    if not is_string(key) or find(key, '^%s+$') then
        fatalf('key must be non-empty string')
    end
    self.value[key] = val
end

--- delete
--- @param key string
--- @return any val
function Session:delete(key)
    if not is_string(key) then
        fatalf('key must be string')
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
        fatalf('key must be string')
    end
    return self.value[key]
end

--- consume
--- @param key string
--- @return any val
function Session:consume(key)
    if not is_string(key) then
        fatalf('key must be string')
    end

    local val = self.value[key]
    if val then
        -- delete value after get it
        self.value[key] = nil
    end

    return val
end

--- save
--- @param attr table?
--- @return string? cookie
--- @return any err
function Session:save(attr)
    if attr == nil then
        attr = {}
    elseif not is_table(attr) then
        fatalf('attr must be table')
    end

    local ok, err = Store:set(self.id, self.value, ATTR.maxage)
    if not ok then
        return nil, errorf('failed to Store:set()', err)
    end

    return bake_cookie(NAME, self.id, bake_attributes({}, attr))
end

--- destroy
--- @param attr table?
--- @return string? void_cookie
--- @return any err
function Session:destroy(attr)
    if attr == nil then
        attr = {}
    elseif not is_table(attr) then
        fatalf('attr must be table')
    end

    local id, err = uuid4str()
    if not id then
        return nil, errorf('failed to uuid4str()', err)
    end

    local ok
    ok, err = Store:delete(self.id)
    if not ok then
        return nil, errorf('failed to Store:delete()', err)
    end

    -- clear
    self.id = id
    self.value = {}
    return bake_cookie(NAME, 'void', bake_attributes({
        maxage = -60,
    }, attr))
end

return {
    new = require('metamodule').new(Session),
    set_store = set_store,
    get_name = get_name,
    set_name = set_name,
    get_attr = get_attr,
    set_attr = set_attr,
    -- export default config
    DEFAULT_NAME = DEFAULT_NAME,
    DEFAULT_PATH_ATTR = DEFAULT_PATH_ATTR,
    DEFAULT_MAXAGE_ATTR = DEFAULT_MAXAGE_ATTR,
    DEFAULT_SECURE_ATTR = DEFAULT_SECURE_ATTR,
    DEFAULT_HTTPONLY_ATTR = DEFAULT_HTTPONLY_ATTR,
    DEFAULT_SAMESITE_ATTR = DEFAULT_SAMESITE_ATTR,
}


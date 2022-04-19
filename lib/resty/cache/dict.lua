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
local isa = require('isa')
local is_boolean = isa.boolean
local is_string = isa.string
local is_uint = isa.uint
local yyjson = require('yyjson')
local format = require('print').format
local errorf = require('reflex.errorf')

--- is_valid_key
--- @param key string
--- @return boolean ok
--- @return string err
local function is_valid_key(key)
    if not is_string(key) or not find(key, '^[a-zA-Z0-9_%-]+$') then
        return false, format('key must be string of %q', '^[a-zA-Z0-9_%-]+$')
    end
    return true
end

--- @class Cache
--- @field dict userdata
local Cache = {}
Cache.__index = Cache

--- set
--- @param key string
--- @param val string
--- @param ttl integer
--- @return boolean ok
--- @return string err
function Cache:set(key, val, ttl)
    local ok, err = is_valid_key(key)
    if not ok then
        return false, err
    elseif val == nil then
        return false, format('val must not be nil')
    elseif ttl ~= nil and (not is_uint(ttl) or ttl < 1) then
        return false, format('ttl must be integer greater than 0')
    end

    local data
    data, err = yyjson.encode({
        val = val,
        ttl = ttl,
    })
    if err then
        return false, format('failed to encode value: %s', err)
    end

    return self.dict:safe_set(key, data, ttl)
end

--- get
--- @param key string
--- @param touch boolean
--- @return string val
--- @return string err
function Cache:get(key, touch)
    local ok, err = is_valid_key(key)
    if not ok then
        return nil, err
    elseif touch ~= nil and not is_boolean(touch) then
        return nil, 'touch must be boolean'
    end

    local data = self.dict:get(key)
    if not data then
        return nil
    end

    local item = yyjson.decode(data)
    if not item then
        -- remove corrupt data
        self.dict.set(key, nil)
        return nil
    elseif touch then
        -- update ttl
        ok, err = self.dict:safe_set(key, data, item.ttl)
        if not ok then
            return nil, err
        end
    end

    return item.val
end

--- del
--- @param key string
--- @return boolean ok
--- @return string err
function Cache:del(key)
    local ok, err = is_valid_key(key)
    if not ok then
        return false, err
    end
    return self.dict:safe_set(key, nil)
end

--- new
--- @param name string
--- @return Cache
local function new(name)
    local dict = ngx.shared[name]
    if not dict then
        errorf(2, 'dict %q not found', name)
    end

    return setmetatable({
        dict = dict,
    }, Cache)
end

return {
    new = new,
}


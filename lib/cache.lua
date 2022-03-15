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
local time = os.time
local format = format
local is_boolean = is_boolean
local is_string = is_string
local is_uint = is_uint
local find = string.find

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
--- @field data table
local Cache = {}
Cache.__index = Cache

--- set
--- @param key string
--- @param val any
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

    self.data[key] = {
        val = val,
        ttl = ttl,
        exp = ttl and time() + ttl or nil,
    }
    return true
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

    local item = self.data[key]
    if not item then
        return nil
    elseif item.exp then
        local t = time()
        if item.exp <= t then
            self.data[key] = nil
            return nil
        elseif touch then
            item.exp = t + item.ttl
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
    elseif self.data[key] ~= nil then
        self.data[key] = nil
        return true
    end
    return false
end

--- new
--- @return Cache
--- @return string err
local function new()
    return setmetatable({
        data = {},
    }, Cache)
end

return {
    new = new,
}


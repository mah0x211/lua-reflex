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
local time = os.time
local find = string.find
local isa = require('isa')
local is_boolean = isa.boolean
local is_string = isa.string
local is_uint = isa.uint
local format = require('print').format

--- is_valid_key
--- @param key string
--- @return boolean ok
--- @return any err
local function is_valid_key(key)
    if not is_string(key) or not find(key, '^[a-zA-Z0-9_%-]+$') then
        return false, format('key must be string of %q', '^[a-zA-Z0-9_%-]+$')
    end
    return true
end

--- @class reflex.cache
--- @field data table
local Cache = {}

--- new
--- @return reflex.cache
function Cache:init()
    self.data = {}
    return self
end

--- set_item
--- @param key string
--- @param val any
--- @param ttl integer
--- @return boolean ok
--- @return any err
function Cache:set_item(key, val, ttl)
    self.data[key] = {
        val = val,
        ttl = ttl,
        exp = ttl and time() + ttl or nil,
    }
    return true
end

--- set
--- @param key string
--- @param val any
--- @param ttl integer
--- @return boolean ok
--- @return any err
function Cache:set(key, val, ttl)
    local ok, err = is_valid_key(key)
    if not ok then
        return false, err
    elseif val == nil then
        return false, format('val must not be nil')
    elseif ttl ~= nil and (not is_uint(ttl) or ttl < 1) then
        return false, format('ttl must be integer greater than 0')
    end

    return self:set_item(key, val, ttl)
end

--- get_item
--- @param key string
--- @param touch boolean
--- @return string|nil val
--- @return any err
function Cache:get_item(key, touch)
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

--- get
--- @param key string
--- @param touch boolean
--- @return string val
--- @return any err
function Cache:get(key, touch)
    local ok, err = is_valid_key(key)
    if not ok then
        return nil, err
    elseif touch ~= nil and not is_boolean(touch) then
        return nil, 'touch must be boolean'
    end

    return self:get_item(key, touch)
end

--- del_item
--- @param key string
--- @return boolean ok
--- @return any err
function Cache:del_item(key)
    if self.data[key] ~= nil then
        self.data[key] = nil
        return true
    end
    return false
end

--- del
--- @param key string
--- @return boolean ok
--- @return any err
function Cache:del(key)
    local ok, err = is_valid_key(key)
    if not ok then
        return false, err
    end

    return self:del_item(key)
end

--- evict
--- @return boolean ok
--- @return any err
function Cache:evict()
    return true
end

return {
    new = require('metamodule').new(Cache),
}


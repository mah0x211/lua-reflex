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
local error = error
local lower = string.lower
local find = string.find
local format = string.format
local remove = table.remove
local setmetatable = setmetatable
local capitalize = require('string.capitalize')
local isa = require('isa')
local is_table = isa.table
local is_string = isa.string

local KEY_PATTERN = '^%w[%w_-]*$'

--- is_valid_key
--- @param key any
--- @return boolean ok
--- @return string err
local function is_valid_key(key)
    if is_string(key) and find(key, KEY_PATTERN) ~= nil then
        return true
    end

    return false, format('key must be string matching the following pattern %q',
                         KEY_PATTERN)
end

--- copy_values
--- @param vals string[]
--- @return string[] copied
--- @return string err
local function copy_values(vals)
    local arr = {}

    for i, v in ipairs(vals) do
        if not is_string(v) then
            return nil, format('val#%d must be string', i)
        end
        arr[i] = v
    end

    -- empty-table will be nil
    if #arr == 0 then
        return nil
    end

    return arr
end

--- @class Header
--- @field list table<integer, table<string, string[]>>
--- @field dict table<string, table<string, string[]>>
--- @field header userdata
local Header = {}
Header.__index = Header

--- set
--- @param key string
--- @param val string|string[]
--- @return boolean ok
--- @return string? err
function Header:set(key, val)
    local ok, err = is_valid_key(key)

    if not ok then
        error(err, 2)
    elseif val ~= nil then
        if is_string(val) then
            val = {
                val,
            }
        elseif is_table(val) then
            val, err = copy_values(val)
            if err then
                error(err, 2)
            end
        else
            error('val must be string or string[]', 2)
        end
    end

    local lkey = lower(key)
    if val == nil then
        -- remove key
        local item = self.dict[lkey]
        if item then
            remove(self.list, item.idx)
            self.dict[lkey] = nil
            return true
        end
        return false
    end

    local item = self.dict[lkey]
    if item then
        -- update value
        item.val = val
    else
        -- set new item
        item = {
            idx = #self.list + 1,
            key = capitalize(key),
            val = val,
        }
        self.list[item.idx] = item
        self.dict[lkey] = item
    end

    return true
end

--- add
--- @param key string
--- @param val string|string[]
--- @return boolean ok
function Header:add(key, val)
    local ok, err = is_valid_key(key)

    if not ok then
        error(err, 2)
    elseif is_string(val) then
        val = {
            val,
        }
    elseif is_table(val) then
        val, err = copy_values(val)
        if err then
            error(err, 2)
        end
    else
        error('val must be string or string[]', 2)
    end

    local lkey = lower(key)
    local item = self.dict[lkey]
    if item then
        -- append values
        local arr = item.val
        for _, v in ipairs(val) do
            arr[#arr + 1] = v
        end
    else
        -- set new item
        item = {
            idx = #self.list + 1,
            key = capitalize(key),
            val = val,
        }
        self.list[item.idx] = item
        self.dict[lkey] = item
    end

    return true
end

--- get
--- @param key string
--- @return string key
--- @return string[] val
function Header:get(key)
    if not is_string(key) then
        error('key must be string', 2)
    end

    local item = self.dict[lower(key)]
    if item then
        return item.val, item.key
    end
    return nil
end

--- each
--- @return function iterator
function Header:each()
    local list = self.list
    return function(_, ...)
        local idx, item = next(list, ...)
        if idx then
            return idx, item.key, item.val
        end
    end
end

--- new
--- @return Header
local function new()
    return setmetatable({
        list = {},
        dict = {},
    }, Header)
end

return {
    new = new,
}

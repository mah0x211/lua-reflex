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
local yyjson = require('yyjson')
local format = require('print').format
local libmdbx = require('libmdbx')
local errno = libmdbx.errno

--- @class reflex.cache.mdbx
local Cache = {}

--- init
--- @param pathname string
--- @return reflex.cache.mdbx
--- @return string err
function Cache:init(pathname)
    local env, err = libmdbx.new()
    if err then
        return nil, err
    end

    local ok
    ok, err = env:open(pathname)
    if not ok then
        return nil, err
    end
    self.env = env

    return self
end

--- begin
--- @param f function
--- @param failval any
--- @return any res
--- @return string err
function Cache:begin(f, failval)
    local txn, err = self.env:begin()
    if not txn then
        return failval, format('failed to begin transaction: %s', err)
    end

    local ok
    ok, err = txn:dbi_open()
    if not ok then
        txn:abort()
        return failval, format('failed to open dbi: %s', err)
    end

    local res
    res, err = f(txn)
    if err then
        txn:abort()
        return failval, err
    end

    ok, err = txn:commit()
    if not ok then
        return failval, format('failed to commit: %s', err)
    end

    return res
end

--- set_item
--- @param key string
--- @param val any
--- @param ttl integer
--- @return boolean ok
--- @return string err
function Cache:set_item(key, val, ttl)
    local data, err = yyjson.encode({
        val = val,
        ttl = ttl,
        exp = ttl and time() + ttl or nil,
    })
    if err then
        return false, format('failed to encode value: %s', err)
    end

    return self:begin(function(txn)
        local ok, terr = txn:op_upsert(key, data)
        if not ok then
            return false, format('failed to upsert: %s', terr)
        end

        return true
    end, false)

end

--- get_item
--- @param key string
--- @param touch boolean
--- @return string val
--- @return string err
function Cache:get_item(key, touch)
    return self:begin(function(txn)
        local data, err = txn:get(key)
        if err then
            return nil, format('failed to get: %s', err)
        elseif not data then
            return nil
        end

        local item
        item, err = yyjson.decode(data)
        if err then
            return nil, format('failed to decode: %s', err)
        end

        if item.exp then
            local t = time()
            local ok

            if item.exp <= t then
                ok, err = txn:del(key)
                if not ok then
                    return nil, format('failed to delete expired item: %s', err)
                end
                item.val = nil
            elseif touch then
                item.exp = t + item.ttl
                data, err = yyjson.encode(item)
                if err then
                    return nil, format('failed to encode value: %s', err)
                end

                ok, err = txn:op_update(key, data)
                if not ok then
                    return nil, format('failed to update value: %s', err)
                end
            end
        end

        return item.val
    end)
end

--- del_item
--- @param key string
--- @return boolean ok
--- @return string err
function Cache:del_item(key)
    return self:begin(function(txn)
        local ok, err, eno = txn:del(key)
        if ok then
            return true
        elseif eno == errno.NOTFOUND.errno then
            return false
        end
        return false, err
    end, true)
end

return {
    new = require('metamodule').new(Cache, 'reflex.cache'),
}


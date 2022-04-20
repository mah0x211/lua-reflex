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
local find = string.find
local format = string.format
local is_string = require('isa').string

--- @class reflex.resty.Response : reflex.Response
--- @field data table
local Response = {}

--- flush
--- @param wait boolean
--- @return boolean ok
--- @return string err
function Response:flush(wait)
    local ok, err = ngx.flush(wait)
    if not ok then
        return false, err
    end
    return true
end

--- write
--- @param str string
--- @return boolean ok
--- @return string err
function Response:write(str)
    if str == nil then
        str = ''
    elseif not is_string(str) then
        error('str must be string', 2)
    end

    if not ngx.headers_sent then
        -- add headers
        local header = ngx.header
        if self.json == true then
            header['Content-Type'] = 'application/json'
        end
        for _, k, v in self.header:each() do
            header[k] = v
        end

        local te = self.header:get('transfer-encoding')
        for _, v in ipairs(te or {}) do
            if find(v, 'chunked', nil, true) then
                self.chunked = true
            end
        end

        if not self.chunked then
            header['Content-Length'] = #str
        end

        ngx.status = self.status or 200
    end

    -- send data by chunked transfer-encoded
    if self.chunked then
        local len = format("%x\r\n", #str)
        str = len .. str .. "\r\n"
    end

    local ok, err = ngx.print(str)
    if not ok then
        return false, err
    end

    return true
end

return {
    new = require('metamodule').new(Response, 'reflex.response'),
}


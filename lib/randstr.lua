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
local concat = table.concat
local sub = string.sub
local match = string.match
local random = math.random
local tostring = tostring
local encodeURL = require('base64mix').encodeURL

math.randomseed(os.time())

--- random_bytes
--- @param n integer
--- @param encode boolean
--- @return string url
--- @return string err
local function randstr(n, encode)
    local nbyte = 0
    local src = {}

    while nbyte < n do
        local s = match(tostring(random()), '%.(%d+)')
        nbyte = nbyte + #s
        if nbyte > n then
            s = sub(s, 1, #s - (nbyte - n))
        end
        src[#src + 1] = s
    end

    if encode then
        return sub(encodeURL(concat(src)), 1, n)
    end
    return concat(src)
end

return randstr

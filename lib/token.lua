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
local sub = string.sub
local is_string = require('isa').string
local hmacsha = require('hmac').sha224
local randstr = require('reflex.randstr')
-- constants
-- N byte = 128 bit / 8 bit
local MSG_LEN = 128 / 8
-- N byte = SHA-224(224 bit) / 8 bit * 2(HEX)
local SHA1_LEN = 224 / 8 * 2
-- SHA1_LEN(160bit) + DELIMITER('.') + MSG_LEM
local TOKEN_LEN = SHA1_LEN + 1 + MSG_LEN

--- compute
--- @param key string
--- @param msg any
--- @return string
local function compute(msg, key)
    local ctx = hmacsha(key)
    ctx:update(msg)
    return ctx:final()
end

--- verify
--- @param key string
--- @param token string
--- @return boolean ok
--- @return string err
local function verify(key, token)
    if not is_string(key) then
        error('key must be string', 2)
    elseif not is_string(token) then
        error('token must be string', 2)
    elseif #token ~= TOKEN_LEN or sub(token, SHA1_LEN + 1, SHA1_LEN + 1) ~= '.' then
        return false
    end

    local msg = sub(token, -MSG_LEN)
    return compute(msg, key) == sub(token, 1, SHA1_LEN)
end

--- generate
--- @param key string
--- @return string str
--- @return string err
local function generate(key)
    if not is_string(key) then
        error('key must be string', 2)
    end

    local msg = randstr(MSG_LEN)
    return compute(msg, key) .. '.' .. msg
end

return {
    generate = generate,
    verify = verify,
}

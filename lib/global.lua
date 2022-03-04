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
local type = type
for k, v in pairs(require('isa')) do
    if type(v) == 'function' then
        _G['is_' .. string.lower(k)] = v
    end
end

_G.unpack = require('unpack')

local assert = require('assert')
_G.assert = assert

local dump = require('dump')
_G.dump = dump

local error = require('error')
_G.error = error

_G.print = require('print')

local format = print.format
_G.format = format

local function printv(...)
    print(dump({
        ...,
    }))
end
_G.printv = printv

local function errorf(...)
    local lv = ...
    if type(lv) == 'number' then
        error(format(select(2, ...)), lv)
    end
    error(format(...), 2)
end
_G.errorf = errorf

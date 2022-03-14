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

local isa = require('isa')
_G.is_boolean = isa['boolean']
_G.is_false = isa['false']
_G.is_file = isa['file']
_G.is_finite = isa['finite']
_G.is_function = isa['function']
_G.is_int = isa['int']
_G.is_int16 = isa['int16']
_G.is_int32 = isa['int32']
_G.is_int8 = isa['int8']
_G.is_nan = isa['nan']
_G.is_nil = isa['nil']
_G.is_none = isa['none']
_G.is_number = isa['number']
_G.is_string = isa['string']
_G.is_table = isa['table']
_G.is_thread = isa['thread']
_G.is_true = isa['true']
_G.is_uint = isa['uint']
_G.is_uint16 = isa['uint16']
_G.is_uint32 = isa['uint32']
_G.is_uint8 = isa['uint8']
_G.is_unsigned = isa['unsigned']
_G.is_userdata = isa['userdata']

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
        error(format(select(2, ...)), lv + 1)
    end
    error(format(...), 2)
end
_G.errorf = errorf


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
--- modules
local find = string.find
local isa = require('isa')
local is_table = isa.table
local is_string = isa.string
local errorf = require('reflex.errorf')
local resty_proxy = require('reflex.resty').proxy
-- constants
local METHOD_PAT = '^[a-zA-Z]+$'

--- request
--- @param uri string
--- @param opts table
--- @return table res
--- @return string err
local function request(uri, opts)
    if opts == nil then
        opts = {}
    end

    if not is_string(uri) then
        errorf(2, 'uri must be string')
    elseif not is_table(opts) then
        errorf(2, 'opts must be table')
    end

    if opts.method == nil then
        opts.method = 'GET'
    elseif not is_string(opts.method) and not find(opts.method, METHOD_PAT) then
        errorf(2, 'opts.method must be the following string pattern: %q',
               METHOD_PAT)
    end

    if opts.header == nil then
        opts.header = {}
    elseif not is_table(opts.header) then
        errorf(2, 'opts.header must be table')
    end

    if opts.header['User-Agent'] == nil then
        opts.header['User-Agent'] = 'reflex'
    end

    return resty_proxy(uri, opts)
end

return {
    request = request,
}


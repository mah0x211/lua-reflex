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
-- init for libmagic
local sub = string.sub
local gsub = string.gsub
local errorf = require('error').format
local extname = require('extname')
local mediatypes = require('mediatypes').new()
local fatalf = require('reflex.fatalf')
local magic
do
    local libmagic = require('libmagic')
    magic = libmagic.open(libmagic.MIME, libmagic.NO_CHECK_COMPRESS,
                          libmagic.SYMLINK)
    magic:load()
end

--- get_charset
--- @param file string|number|file*
--- @return string? mime
--- @return any err
local function get(file, filename)
    if filename ~= nil and type(filename) ~= 'string' then
        fatalf('filename must be string')
    end

    local res, err = magic(file)
    if not res then
        return nil, errorf('failed to magic()', err)
    end

    local ext
    if filename then
        ext = extname(filename)
    elseif type(file) == 'string' then
        ext = extname(file)
    end

    local mime = ext and mediatypes:getmime(sub(ext, 2))
    if not mime then
        return res
    end

    res = gsub(res, '^[^;]+', mime)
    return res
end

return {
    get = get,
}


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
local popen = io.popen
local find = string.find
local format = string.format
local match = string.match
local type = type

--- which
--- @param filename string
--- @return string pathname
local function which(filename)
    if type(filename) ~= 'string' then
        error('filename must be string', 2)
    end

    local errors = {}
    local cmds = {
        'type -p %q 2>&1',
        'which %q 2>&1',
    }
    for _, cmd in ipairs(cmds) do
        local f = popen(format(cmd, filename))
        local res = f:read('*a')
        f:close()

        if #res > 0 then
            local pathname = match(res, '^%s*([^%s]+)%s*$')
            if pathname and not find(pathname, '%s') then
                return pathname
            end
            errors[#errors + 1] = match(res, '^(.+)%s+$')
        end
    end

    if #errors == #cmds then
        error(concat(errors, ', '), 2)
    end
end

return which

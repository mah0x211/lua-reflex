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
-- module
require('reflex.global')
local print = print
local concat = table.concat
local format = string.format
local gsub = string.gsub
local match = string.match
local sub = string.sub
local open = io.open
local remove = os.remove
local exec = require('reflex.fs').exec
-- constants
local ROCKSPEC_TMPL = [[
package = $PACKAGE
version = $VERSION
source = {
    url = ''
}
build = {
    type = 'builtin',
    modules = {},
}
dependencies = {
$DEPENDENCIES
}
]]

--- install requirements
--- @param pathname string
--- @return boolean installed
local function install(pathname)
    local list = {}
    local f, err = open(pathname)
    if f then
        -- list dependencies
        for line in f:lines() do
            line = match(line, '^%s*(.+)%s*$')
            if #line > 0 and sub(line, 1, 1) ~= '#' then
                list[#list + 1] = format('    %q', line)
            end
        end
        f:close()
    elseif err then
        errorf('failed to open %q', pathname)
    end

    -- dependencies
    if #list > 0 then
        -- create rockspec file
        local pkgname = 'reflex-app'
        local version = 'dev-1'
        local content = gsub(ROCKSPEC_TMPL, '$([^%s]+)', {
            PACKAGE = format('%q', pkgname),
            VERSION = format('%q', version),
            DEPENDENCIES = concat(list, ',\n'),
        })
        pathname = format('tmp/%s-%s.rockspec', pkgname, version)

        --
        -- TODO: install modules from the non-default repositories
        --
        print.info('install dependencies')
        f = assert(open(pathname, 'w'))
        assert(f:write(content))
        f:close()
        assert(exec('luarocks', {
            'make',
        }, 'tmp'))

        print.info('remove app package')
        assert(exec('luarocks', {
            'remove',
            pkgname,
        }, 'tmp'))
        assert(remove(pathname))

        return true
    end
end

return install


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
local unpack = require('unpack')
local error = error
local concat = table.concat
local type = type
local execvp = require('exec').execvp

local function noop()
    -- do nothing
end

--- exec
--- @param pathname string
--- @param argv string[]
--- @param pwd string
--- @param stdout function
--- @param stderr function
--- @return boolean ok
--- @return error err
local function exec(pathname, argv, pwd, stdout, stderr)
    stdout = stdout or noop
    stderr = stderr or noop
    if type(stdout) ~= 'function' then
        error('stdout must be function', 2)
    elseif type(stderr) ~= 'function' then
        error('stderr must be function', 2)
    end

    -- print command and arguments
    stdout(pathname, unpack(argv))

    -- execute
    local p, err = execvp(pathname, argv, pwd)
    if err then
        return false, err
    end

    -- print stdout
    for line in p.stdout:lines() do
        stdout(line)
    end

    -- print stderr
    local errlines = {}
    for line in p.stderr:lines() do
        stderr(line)
        errlines[#errlines + 1] = line
    end

    local res, werr = p:waitpid()
    if werr then
        return false, werr
    elseif not res.exit or res.exit ~= 0 then
        return false, concat(errlines)
    end
    return true, p.stdout:read('*a')
end

return exec

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
local type = type
local unpack = require('unpack')
local execvp = require('exec').execvp
local errorf = require('error').format
local fatalf = require('error').fatalf

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
--- @return string res
local function exec(pathname, argv, pwd, stdout, stderr)
    stdout = stdout or noop
    stderr = stderr or noop
    if type(stdout) ~= 'function' then
        fatalf('stdout must be function')
    elseif type(stderr) ~= 'function' then
        fatalf('stderr must be function')
    end

    -- print command and arguments
    stdout(pathname, unpack(argv))

    -- execute
    local p, err = execvp(pathname, argv, pwd)
    if err then
        return false, err
    end

    -- print stdout
    local outlines = {}
    for line in p.stdout:lines() do
        stdout(line)
        if stdout == noop then
            outlines[#outlines + 1] = line
        end
    end

    -- print stderr
    local errlines = {}
    for line in p.stderr:lines() do
        stderr(line)
        errlines[#errlines + 1] = line
    end

    local res, werr = p:waitpid()
    if werr then
        return false, errorf('failed to waitpid()', werr)
    elseif not res.exit or res.exit ~= 0 then
        return false, #errlines > 0 and
                   errorf('failed to exec(): %s', concat(errlines, '\n')) or nil
    end

    return true, #outlines > 0 and
               errorf('failed to exec(): %s', concat(outlines, '\n')) or nil
end

return exec

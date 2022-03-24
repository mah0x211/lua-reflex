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
local assert = assert
local basedir = require('basedir')
local getcwd = require('getcwd')
local exec = require('reflex.exec')
-- constants
local CWD = assert(getcwd())
local RootDir = assert(basedir.new(CWD))
local TrashDir = './trash/'

--- @alias error userdata
--- @alias exec.process userdata

--- realpath
--- @param pathname string
--- @return string apath
--- @return string err
--- @return string rpath
local function realpath(pathname)
    return RootDir:realpath(pathname)
end

--- mkdir
--- @param pathname string
--- @return boolean ok
--- @return string err
local function mkdir(pathname)
    return RootDir:mkdir(pathname)
end

--- open
--- @param pathname string
--- @return file* f
--- @return string err
local function open(pathname, mode)
    return RootDir:open(pathname, mode)
end

--- read
--- @param pathname string
--- @return string content
--- @return string err
local function read(pathname)
    return RootDir:read(pathname)
end

--- write
--- @param pathname string
--- @param content string
--- @return boolean ok
--- @return string err
local function write(pathname, content)
    local f, err = open(pathname, 'w')
    if not f then
        return false, err
    end

    local _
    _, err = f:write(content)
    f:close()
    if err then
        return false, err
    end

    return true
end

--- write
--- @param pathname string
--- @param content string
--- @return boolean ok
--- @return string err
local function write_if_not_exist(pathname, content)
    local apath, err = realpath(pathname)
    if err then
        return false, err
    elseif apath then
        return true
    end

    return write(pathname, content)
end

--- getpwd
--- @return string
local function getpwd()
    return CWD
end

local function chdir(pathname)
    pathname = realpath(pathname)
    return exec('chdir', {
        pathname,
    })
end

local function unlink(pathname)
    pathname = realpath(pathname)
    return exec('mv', {
        pathname,
        TrashDir,
    })
end

return {
    realpath = realpath,
    open = open,
    read = read,
    write = write,
    write_if_not_exist = write_if_not_exist,
    getpwd = getpwd,
    chdir = chdir,
    mkdir = mkdir,
    unlink = unlink,
}

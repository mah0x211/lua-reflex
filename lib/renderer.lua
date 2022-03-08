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
local require = require
local new_basedir = require('basedir').new
local yyjson_encode = require('yyjson').encode
local new_rez = require('rez').new
local escape_html = require('rez.escape').html

--- @class Renderer
--- @field rootdir userdata
--- @field rez userdata
local Renderer = {}
Renderer.__index = Renderer

--- render
--- @param data table
--- @param pathname string|nil
--- @return string res
--- @return string err
function Renderer:render(data, pathname)
    data = data or {}
    if type(data) ~= 'table' then
        error('data must be table')
    elseif pathname == nil then
        return yyjson_encode(data)
    elseif type(pathname) ~= 'string' then
        error('pathname must be string', 2)
    end

    return self.rez:render(pathname, data)
end

--- exists
--- @param pathname string
--- @return boolean ok
function Renderer:exists(pathname)
    if type(pathname) ~= 'string' then
        error('pathname must be string', 2)
    end
    return self.rez:exists(pathname)
end

--- del
--- @param pathname string
--- @return boolean ok
function Renderer:del(pathname)
    if type(pathname) ~= 'string' then
        error('pathname must be string', 2)
    end
    return self.rez:del(pathname)
end

--- add
--- @param pathname string
--- @return boolean ok
--- @return string err
function Renderer:add(pathname)
    if type(pathname) ~= 'string' then
        error('pathname must be string', 2)
    end

    local content, err = self.rootdir:read(pathname)
    if not content then
        return false, err
    end

    return self.rez:add(pathname, content)
end

--- new
--- @param rootdir
--- @return Renderer
--- @return string err
local function new(rootdir, follow_symlink)
    if type(rootdir) ~= 'string' then
        error('rootdir must be string', 2)
    elseif follow_symlink ~= nil and type(follow_symlink) ~= 'boolean' then
        error('follow_symlink must be boolean', 2)
    end

    local renderer = setmetatable({
        rootdir = new_basedir(rootdir, follow_symlink),
    }, Renderer)
    renderer.rez = new_rez({
        escape = escape_html,
        loader = function(_, pathname)
            return renderer:add(pathname)
        end,
    })

    return renderer
end

return new


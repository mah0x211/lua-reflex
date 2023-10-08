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
local isa = require('isa')
local is_boolean = isa.boolean
local is_table = isa.table
local is_string = isa.string
local require = require
local new_basedir = require('basedir').new
local new_rez = require('rez').new
local errorf = require('error').format
local fatalf = require('error').fatalf
local ENOENT = require('errno').ENOENT

--- default_helpers
--- @return table env
local function default_helpers()
    return {
        format = require('print').format,
        capitalize = require('string.capitalize'),
        contains = require('string.contains'),
        split = require('string.split'),
        trim = require('string.trim'),
    }
end

--- @class reflex.renderer
--- @field rootdir userdata
--- @field rez userdata
--- @field cache boolean
local Renderer = {}

--- init
--- @param rootdir string
--- @param follow_symlink boolean
--- @param cache boolean
--- @param env table
--- @return reflex.renderer
function Renderer:init(rootdir, follow_symlink, cache, env)
    local tmpl_env = default_helpers()

    if not is_string(rootdir) then
        fatalf('rootdir must be string')
    elseif follow_symlink ~= nil and not is_boolean(follow_symlink) then
        fatalf('follow_symlink must be boolean')
    elseif cache ~= nil and not is_boolean(cache) then
        fatalf('cache must be boolean')
    elseif env ~= nil then
        if not is_table(env) then
            fatalf('env must be table')
        end
        for k, v in pairs(env) do
            tmpl_env[k] = v
        end
    end

    self.rootdir = new_basedir(rootdir, follow_symlink)
    self.cache = cache == true
    self.rez = new_rez({
        loader = function(_, pathname)
            return self:add(pathname)
        end,
        env = tmpl_env,
    })

    return self
end

--- render
--- @param pathname string|nil
--- @param data table
--- @return string res
--- @return any err
function Renderer:render(pathname, data)
    data = data or {}
    if not is_string(pathname) then
        fatalf('pathname must be string')
    elseif not is_table(data) then
        fatalf('data must be table')
    end

    local res, err = self.rez:render(pathname, data)
    -- remove compiled templates
    if not self.cache then
        self.rez:clear()
    end

    if not res then
        return nil, errorf('failed to render()', err)
    end
    return res
end

--- exists
--- @param pathname string
--- @return boolean ok
function Renderer:exists(pathname)
    if not is_string(pathname) then
        fatalf('pathname must be string')
    end
    return self.rez:exists(pathname)
end

--- del
--- @param pathname string
--- @return boolean ok
function Renderer:del(pathname)
    if not is_string(pathname) then
        fatalf('pathname must be string')
    end
    return self.rez:del(pathname)
end

--- add
--- @param pathname string
--- @return boolean ok
--- @return any err
function Renderer:add(pathname)
    if not is_string(pathname) then
        fatalf('pathname must be string')
    end

    local content, err = self.rootdir:read(pathname)
    if err then
        return false, errorf('failed to read()', err)
    elseif not content then
        return false, ENOENT:new()
    end

    local ok
    ok, err = self.rez:add(pathname, content)
    if not ok then
        return false, errorf('failed to add()', err)
    end
    return true
end

Renderer = require('metamodule').new(Renderer)
return Renderer


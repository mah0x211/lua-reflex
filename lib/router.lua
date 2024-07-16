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
local ipairs = ipairs
local next = next
local pairs = pairs
local require = require
local isa = require('isa')
local is_string = isa.string
local is_table = isa.table
local new_fsrouter = require('fsrouter').new
local fatalf = require('error').fatalf

--- @alias fsrouter userdata

--- @class reflex.router
--- @field router fsrouter
local Router = {}

--- init
--- @param rootdir string
--- @param opts table
--- @return reflex.router
--- @return table[] routes
function Router:init(rootdir, opts)
    opts = opts or {}
    if not is_string(rootdir) then
        fatalf(2, 'rootdir must be string')
    elseif opts == nil then
        opts = {}
    elseif not is_table(opts) then
        fatalf(2, 'opts must be table')
    end

    local router, err, routes = new_fsrouter(rootdir, {
        follow_symlink = opts.follow_symlink == true,
        trim_extentions = opts.trim_extentions,
        mimetypes = opts.mimetypes,
        ignore = opts.ignore,
        no_ignore = opts.no_ignore,
        loadfenv = function()
            return _G
        end,
    })
    if not router then
        fatalf(2, 'failed to traverse rootdir: %s', err)
    end

    -- build the routing table for print
    local route_list = {}
    for _, route in ipairs(routes) do
        -- static file
        if not next(route.methods) then
            route_list[#route_list + 1] = {
                method = 'get',
                rpath = route.rpath,
                file = route.file,
                handlers = {},
            }
        end

        for method, handlers in pairs(route.methods) do
            local hlist = {}

            for _, handler in ipairs(handlers) do
                hlist[#hlist + 1] = {
                    method = handler.method,
                    name = handler.name,
                }
            end

            route_list[#route_list + 1] = {
                method = method,
                rpath = route.rpath,
                file = route.file,
                handlers = hlist,
            }
        end
    end

    self.router = router
    return self, route_list
end

--- lookup
--- @param pathname string
--- @return table route
--- @return any err
--- @return table glob
function Router:lookup(pathname)
    return self.router:lookup(pathname)
end

Router = require('metamodule').new(Router)

return Router

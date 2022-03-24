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
require('reflex.global')
local assert = assert
local error = error
local ipairs = ipairs
local lower = string.lower
local next = next
local pairs = pairs
local pcall = pcall
local setmetatable = setmetatable
local tostring = tostring
local type = type
local require = require
local new_fsrouter = require('fsrouter').new
local status = require('reflex.status')
--- constants
local OK = status.OK
local NOT_FOUND = status.NOT_FOUND
local METHOD_NOT_ALLOWED = status.METHOD_NOT_ALLOWED
local INTERNAL_SERVER_ERROR = status.INTERNAL_SERVER_ERROR

--- invoke_handlers
--- @param mlist table[]
--- @param req Request
--- @param rsp table
--- @return integer status_code
local function invoke_handlers(mlist, req, rsp)
    for i, imp in ipairs(mlist) do
        local code = imp.fn(req, rsp)
        if code then
            if status[code] then
                return code
            end
            errorf('#%d: %s returns an invalid status code %q', i, imp.name,
                   tostring(code))
        end
    end
end

--- @alias fsrouter userdata

--- @class Router
--- @field router fsrouter
local Router = {}
Router.__index = Router

--- serve
--- @param method string
--- @param pathname string
--- @param req table
--- @param rsp table
--- @return integer status
--- @return string err
--- @return table file
function Router:serve(method, pathname, req, rsp)
    if type(method) ~= 'string' then
        error('method must be string', 2)
    elseif type(pathname) ~= 'string' then
        error('pathname must be string', 2)
    elseif type(req) ~= 'table' then
        error('req must be table', 2)
    elseif type(rsp) ~= 'table' then
        error('rsp must be table', 2)
    elseif type(rsp.header) ~= 'table' then
        error('rsp.header must be table', 2)
    elseif type(rsp.body) ~= 'table' then
        error('rsp.body must be table', 2)
    end

    -- get route
    local route, err, glob = self.router:lookup(pathname)
    if err then
        return INTERNAL_SERVER_ERROR, err
    elseif not route then
        return NOT_FOUND
    end
    req.params = glob

    -- no method in route
    if not next(route.methods) then
        -- allow only the GET method
        if lower(method) == 'get' then
            return OK, nil, route.file
        end
        return METHOD_NOT_ALLOWED
    end

    local mlist = route.methods[lower(method)] or route.methods.any or
                      route.filters.all
    if not mlist then
        return METHOD_NOT_ALLOWED
    end

    local ok, res = pcall(invoke_handlers, mlist, req, rsp)
    if not ok then
        return INTERNAL_SERVER_ERROR, res
    end

    return res or OK, nil, route.file
end

--- new
--- @param rootdir string
--- @param opts table
--- @return Router
--- @return table[] routes
local function new(rootdir, opts)
    opts = opts or {}
    if type(rootdir) ~= 'string' then
        error('rootdir must be string', 2)
    elseif type(opts) ~= 'table' then
        error('opts must be table', 2)
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
    assert(router, err)

    -- build the routing table for print
    local route_list = {}
    for _, route in ipairs(routes) do
        -- filter.all
        if route.filters.all then
            local hlist = {}
            for _, handler in ipairs(route.filters.all) do
                hlist[#hlist + 1] = {
                    method = 'all',
                    name = handler.stat.rpath,
                }
            end
            route_list[#route_list + 1] = {
                method = 'all',
                rpath = route.rpath,
                file = route.file,
                handlers = hlist,
            }
        end

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

    return setmetatable({
        router = router,
    }, Router), route_list
end

return new


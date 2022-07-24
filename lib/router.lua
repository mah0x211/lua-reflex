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
local ipairs = ipairs
local lower = string.lower
local next = next
local pairs = pairs
local xpcall = xpcall
local traceback = debug.traceback
local tostring = tostring
local type = type
local require = require
local format = string.format
local isa = require('isa')
local is_string = isa.string
local is_table = isa.table
local new_fsrouter = require('fsrouter').new
local errorf = require('reflex.errorf')
local code2name = require('reflex.status').code2name

--- invoke_handlers
--- @param res reflex.response
--- @param req reflex.Request
--- @param mlist table[]
--- @return integer status_code
local function invoke_handlers(res, req, mlist)
    for i, imp in ipairs(mlist) do
        local code = imp.fn(req, res)
        if code then
            if code2name(code) then
                return code
            end
            errorf('#%d: %s returns an invalid status code %q', i, imp.name,
                   tostring(code))
        end
    end

    return res:ok()
end

--- @alias fsrouter userdata

--- @class reflex.router
--- @field router fsrouter
local Router = {}

--- serve
--- @param res reflex.response
--- @param req reflex.Request
--- @return integer status
--- @return table file
function Router:serve(res, req)
    if not is_table(res) then
        error('res must be table', 2)
    elseif not is_table(res.header) then
        error('res.header must be table', 2)
    elseif not is_table(res.body) then
        error('res.body must be table', 2)
    elseif not is_table(req) then
        error('req must be table', 2)
    elseif not is_string(req.method) then
        error('req.method must be string', 2)
    elseif not is_string(req.path) then
        error('req.path must be string', 2)
    elseif not is_table(req.header) then
        error('req.header must be table', 2)
    end

    -- get route
    local route, err, glob = self.router:lookup(req.path)
    if err then
        return res:internal_server_error(err)
    elseif not route then
        return res:not_found(format('%q not found', req.path))
    end
    req.params = glob
    req.route_uri = route.rpath

    -- no method in route
    if not next(route.methods) then
        -- allow only the GET method for request to file
        if route.file and lower(req.method) == 'get' then
            return res:ok(), route.file
        end
        return res:method_not_allowed()
    end

    local mlist = route.methods[lower(req.method)] or route.methods.any
    if not mlist then
        return res:method_not_allowed()
    end

    local ok, rsp = xpcall(function()
        return invoke_handlers(res, req, mlist)
    end, traceback)
    if not ok then
        return res:internal_server_error(rsp)
    end

    return rsp, route.file
end

--- init
--- @param rootdir string
--- @param opts table
--- @return reflex.router
--- @return table[] routes
function Router:init(rootdir, opts)
    opts = opts or {}
    if type(rootdir) ~= 'string' then
        errorf(2, 'rootdir must be string')
    elseif type(opts) ~= 'table' then
        errorf(2, 'opts must be table')
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

Router = require('metamodule').new(Router)

return Router


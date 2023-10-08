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
local lower = string.lower
local format = string.format
local sub = string.sub
local traceback = debug.traceback
local xpcall = require('xpcall')
local isa = require('isa')
local is_table = isa.table
local log = require('reflex.log')
local fatalf = require('error').fatalf
local code2message = require('reflex.status').code2message
local new_renderer = require('reflex.renderer')
local new_router = require('reflex.router')

--- @class reflex
--- @field debug boolean
--- @field router reflex.router
--- @field renderer reflex.renderer
--- @field error_pages table<integer, string>
local Reflex = {}

--- init
--- @param cfg table
--- @return reflex rx
--- @return table routes
function Reflex:init(cfg)
    if not is_table(cfg) then
        fatalf("cfg must be table")
    elseif not is_table(cfg.document) then
        fatalf("cfg.document must be table")
    elseif cfg.document.error_pages ~= nil and
        not is_table(cfg.document.error_pages) then
        fatalf("cfg.document.error_pages must be table")
    end

    -- init router
    local router, routes = new_router(cfg.document.rootdir, cfg.document)

    self.debug = cfg.debug == true
    self.document_cache = cfg.document.cache == true
    self.response_as_json = cfg.response_as_json == true
    self.router = router
    self.renderer = new_renderer(cfg.document.rootdir,
                                 cfg.document.follow_symlink,
                                 cfg.template.cache, cfg.template.env)
    self.error_pages = cfg.document.error_pages or {}
    self.template_files = cfg.template.files

    return self, routes
end

--- is_template
--- @param ext string
--- @return boolean ok
function Reflex:is_template(ext)
    return self.template_files[ext] and true or false
end

--- serve
--- @param res reflex.response
--- @param req reflex.request
--- @return boolean keepalive
function Reflex:serve(res, req)
    local call_ok, ok, err = xpcall(self.request2response, traceback, self, res,
                                    req)

    if not call_ok then
        log.error('failed run handlers:', ok)
        if not res.replied then
            local _
            _, err = res:internal_server_error()
            if err then
                log.error('failed to reply error: %s', err)
            end
        end
        return false
    elseif err then
        log.debug('failed to serve content %q', req.route_uri, err)
        if not res.replied then
            local _
            _, err = res:internal_server_error()
            if err then
                log.error('failed to reply error: %s', err)
            end
        end
        return false
    elseif not ok then
        -- connection closed
        return false
    end
    return res.keepalived
end

--- request2response
--- run handlers for the request and write response to the client.
--- @param res reflex.response
--- @param req reflex.request
--- @return integer? n
--- @return any err
--- @return boolean? timeout
function Reflex:request2response(res, req)
    --- redirect to normalized uri without the trailing slash
    if req.rawpath ~= req.path then
        if req.path ~= '/' and sub(req.path, -1) == '/' then
            req.path = sub(req.path, 1, #req.path - 1)
        end
        return res:moved_permanently(req.path)
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
    res.page = route.file

    -- no handler
    if not next(route.methods) then
        -- allow only the GET method for request to file
        if route.file and lower(req.method) == 'get' then
            return res:ok()
        end
        return res:method_not_allowed()
    end

    -- no handler for request method
    local mlist = route.methods[lower(req.method)] or route.methods.any
    if not mlist then
        return res:method_not_allowed()
    end

    -- invoke handlers
    local nmehtod = #mlist
    for i = 1, nmehtod do
        local imp = mlist[i]
        local ok, timeout

        ok, err, timeout = imp.fn(req, res)
        if ok or err or timeout then
            -- stop method chain if the handler returns a values
            if i < nmehtod then
                log.debug('method chain stopped at #%d: %s', i, imp.name)
            end
            return ok, err, timeout
        end
    end

    if not res.replied then
        return res:ok()
    end
end

--- render_page
--- @param pathname string
--- @param data table
--- @return string str
--- @return any err
function Reflex:render_page(pathname, data)
    return self.renderer:render(pathname, data)
end

--- render_error_page
--- @param code integer
--- @param data table
--- @return string str
--- @return any err
function Reflex:render_error_page(code, data)
    local pathname = self.error_pages[code]
    if not pathname then
        return code2message(code) .. '\n'
    end
    return self.renderer:render(pathname, data)
end

Reflex = require('metamodule').new(Reflex)

return Reflex

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
local error = error
local next = next
local format = string.format
local open = io.open
local isa = require('isa')
local is_table = isa.table
local escape_html = require('rez.escape').html
local log = require('reflex.log')
local encode2json = require('reflex.json').encode
local code2reason = require('reflex.status').code2reason
local code2message = require('reflex.status').code2message
local new_renderer = require('reflex.renderer')
local new_router = require('reflex.router')
local new_request = require('reflex.request')
local new_response = require('reflex.response')
local new_session = require('reflex.session').new

--- constants
local INTERNAL_SERVER_ERROR_JSON = assert(encode2json({
    code = 500,
    status = code2reason(500),
}))

--- @class reflex
--- @field debug boolean
--- @field router Router
--- @field renderer Renderer
--- @field error_pages table<integer, string>
local Reflex = {}

--- init
--- @param cfg table
--- @return reflex rx
--- @return table routes
function Reflex:init(cfg)
    if not is_table(cfg) then
        error("cfg must be table")
    elseif not is_table(cfg.document) then
        error("cfg.document must be table")
    elseif cfg.document.error_pages ~= nil and
        not is_table(cfg.document.error_pages) then
        error("cfg.document.error_pages must be table")
    end

    -- init router
    local router, routes = new_router(cfg.document.rootdir, cfg.document)

    self.debug = cfg.debug == true
    self.document_cache = cfg.document.cache == true
    self.response_as_json = cfg.response_as_json == true
    self.router = router
    self.renderer = new_renderer(cfg.document.rootdir,
                                 cfg.document.follow_symlink, cfg.template.cache)
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

--- write_file
--- @param res reflex.response
--- @param file table
--- @return boolean ok
function Reflex:write_file(res, file)
    local f, err = open(file.pathname, 'r')
    if err then
        -- failed to render file
        log.error('failed to open file %q: %s', file.rpath, err)
        res:internal_server_error()
        self:write_error(res)
        return false
    end

    res.header:set('Content-Type', file.mime)
    local ok
    ok, err = res:write_file(f)
    f:close()
    if ok then
        ok, err = res:flush()
    end

    if ok then
        return true
    elseif err then
        log.error('failed to write file: %s', err)
    end
    return false
end

--- write
--- @param res reflex.response
--- @param msg? string
--- @return boolean ok
function Reflex:write(res, msg)
    local ok, err = res:write(msg)
    if ok then
        ok, err = res:flush()
    end

    if ok then
        return true
    elseif err then
        log.error('failed to write message: %s', err)
    end
    return false
end

--- write_json
--- @param res reflex.response
--- @return boolean ok
function Reflex:write_json(res)
    res.header:set('Cotent-Type', 'application/json')
    if not next(res.body) then
        -- empty json
        return self:write(res, '{}')
    end

    local msg, err = encode2json(res.body)
    if msg then
        return self:write(res, msg)
    end

    log.error('failed to encode response body to JSON: %s', err)
    res:internal_server_error()
    self:write(res, INTERNAL_SERVER_ERROR_JSON)
    return false
end

--- write_template
--- @param res reflex.response
--- @param file table
--- @return boolean ok
function Reflex:write_template(res, file)
    local str, err = self.renderer:render(res.body, file.rpath)
    if err then
        -- failed to render file
        log.alert('failed to render template %q: %s', file.rpath, err)
        res:internal_server_error()
        self:write_error(res)
        return false
    end
    res.header:set('Content-Type', file.mime)
    return self:write(res, str)
end

--- write_redirection
--- @param res reflex.response
--- @return boolean ok
function Reflex:write_redirection(res)
    if self.response_as_json or res.as_json then
        return self:write_json(res)
    end

    res.header:set('Content-Type', 'text/html')
    local code_msg = code2message(res.status)
    local location = escape_html(res.body.redirection.location)
    local msg = format([[<!DOCTYPE html>
<html>
<head><title>%s</title></head>
<body>
<h1>%s</h1>
<p><a href=%q>%s</a></p>
</body>
</html>]], code_msg, code_msg, location, location)
    return self:write(res, msg)
end

--- write_error
--- @param res reflex.response
--- @return boolean ok
function Reflex:write_error(res)
    if self.response_as_json or res.as_json then
        return self:write_json(res)
    end

    res.header:set('Content-Type', 'text/html')
    -- get error page
    local pathname = self.error_pages[res.status]
    if not pathname then
        -- write status message
        return self:write(res, code2message(res.status) .. '\n')
    end

    -- render error page
    local msg, err = self.renderer:render(res.body, pathname)
    if msg then
        return self:write(res, msg)
    end

    log.alert('failed to render error_page %q: %s', pathname, err)
    res:internal_server_error()
    return self:write(res, code2message(res.status) .. '\n')
end

--- serve
--- @param conn net.http.connection
--- @param req net.http.message.request
--- @return boolean keepalive
function Reflex:serve(conn, msg)
    local res = new_response(conn)
    local req, err = new_request(msg)

    res.body.DEBUG = self.debug
    if err then
        log.crit('failed to create request data: %s', err)
        res:internal_server_error()
        self:write_error(res)
        return false
    elseif req.is_normalized then
        --- redirect to uri without the trailing slash
        res:moved_permanently(req.path)
        self:write_error(res)
        return false
    end

    -- start session
    local cookie = req.header:get('cookie', true)
    if cookie then
        cookie = concat(cookie, '; ')
    end

    local session
    session, err = new_session(cookie)
    if not session then
        log.crit('failed to create session: %s', err)
        res:internal_server_error()
        self:write_error(res)
        return false
    end
    req.session = session

    --- detach from framework post-processing when handler calls this function
    local is_detached = false
    res.detach = function()
        is_detached = true
    end

    -- serve contents by router
    local code, file
    code, err, file = self.router:serve(res, req)
    res.detach = nil
    if err then
        log.error(err)
        if is_detached then
            return false
        end
        res:internal_server_error(err)
        self:write_error(res)
        return false
    elseif is_detached then
        return false
    end

    -- save session
    cookie, err = session:save()
    if not cookie then
        log.crit('failed to save session data: %s', err)
        res:internal_server_error()
        self:write_error(res)
        return false
    end
    res.header:add('Set-Cookie', cookie)

    -- reply error response
    if code >= 400 then
        self:write_error(res)
        return false
    elseif code >= 300 then
        return self:write_redirection(res)
    end

    -- reply as json
    if self.response_as_json or res.as_json == true then
        return self:write_json(res)
    end

    -- reply file content
    if file then
        if self.template_files[file.ext] then
            -- treat file as template
            return self:write_template(res, file)
        end
        return self:write_file(res, file)
    end

    -- reply no-content
    res.header:set('Content-Length', tostring(0))
    return self:write(res)
end

--- render_page
--- @param pathname string
--- @param data table
--- @return string str
--- @return any err
function Reflex:render_page(pathname, data)
    return self.renderer:render(data, pathname)
end

Reflex = require('metamodule').new(Reflex)

return Reflex

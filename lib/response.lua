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
local find = string.find
local next = next
local type = type
local fopen = require('io.fopen')
local log = require('reflex.log')
local new_response = require('net.http.message.response').new
local get_mime = require('reflex.mime').get
local code2reason = require('reflex.status').code2reason
local code2message = require('reflex.status').code2message
local generate_token = require('reflex.token').generate
local fatalf = require('error').fatalf
local encode2json = require('yyjson').encode
local bake_cookie = require('cookie').bake
--- constants
local errorf = require('error').format
local ENOENT = require('errno').ENOENT
local EISDIR = require('errno').EISDIR

--- @class reflex.response
--- @field refx reflex
--- @field protected conn net.http.connection
--- @field protected as_json boolean
--- @field protected keepalived boolean
--- @field degug boolean
--- @field replied boolean
--- @field msg net.http.message.response
--- @field header net.http.header
--- @field body table
--- @field page table
local Response = {}

--- init
--- @param refx reflex
--- @param conn net.http.connection
--- @param req reflex.request
--- @param as_json boolean
--- @param debug boolean
--- @return reflex.response
function Response:init(refx, conn, req, as_json, debug)
    self.conn = conn
    self.refx = refx
    self.req = req
    self.as_json = as_json == true
    self.debug = debug == true
    self.replied = false
    self.keepalived = true

    self.message = new_response()
    self.header = self.message.header
    self.body = {}
    return self
end

--- is_keepalive
--- @return boolean
function Response:is_keepalive()
    return self.keepalived
end

--- no_keepalive disable keepalive response
function Response:no_keepalive()
    if self.keepalived then
        self.keepalived = false
        self.header:add('Connection', 'close')
    end
end

--- is_json
--- @return boolean
function Response:is_json()
    return self.as_json
end

--- json enable json response
--- @return reflex.response
function Response:json()
    self.as_json = true
    return self
end

--- set_csrf_cookie
function Response:set_csrf_cookie(httponly)
    if httponly == nil then
        httponly = true
    elseif type(httponly) ~= 'boolean' then
        fatalf('httponly must be boolean')
    end

    local name = 'X-CSRF-Token'
    local token = generate_token(name)
    local cookie = bake_cookie(name, token, {
        path = '/',
        httponly = httponly,
        samesite = 'strict',
    })
    self.header:set('Set-Cookie', cookie)
end

--- save_session
--- @return boolean ok
--- @return any err
function Response:save_session()
    -- save session automatically
    if not self.req then
        return false
    end

    local sess_cookie, err = self.req:save_session()
    if sess_cookie then
        self.header:set('Set-Cookie', sess_cookie)
        return true
    elseif err then
        err = errorf('failed to save session', err)
        log.error(err)
        return false, err
    end
    return false
end

--- flush
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Response:flush()
    local n, err, timeout = self.conn:flush()
    if err then
        return false, errorf('failed to flush()', err)
    elseif not n then
        return false, nil, timeout
    end
    return true
end

--- openfile
--- @param pathname string
--- @return file*? f
--- @return any err
--- @return string? mime
local function openfile(pathname)
    local f, err = fopen(pathname)
    if not f then
        -- failed to open file
        return nil, errorf('failed to fopen()', err)
    end

    local mime
    mime, err = get_mime(f, pathname)
    if not mime then
        f:close()
        return nil, errorf('failed to get_mime()', err)
    end

    return f, nil, mime
end

--- write_file
--- @param pathname string
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Response:write_file(pathname)
    local f, ferr, mime = openfile(pathname)
    if ferr then
        -- failed to open file
        if type(ferr) ~= 'string' and
            (ferr.type == EISDIR or ferr.type == ENOENT) then
            return self:not_found()
        end
        log.error('failed to open file %q: %s', pathname, ferr)
        return self:internal_server_error()
    end
    self.header:set('Content-Type', mime)

    self.replied = true
    local n, err, timeout = self.message:write_file(self.conn, f)
    f:close()
    if err then
        return false, errorf('failed to write_file()', err), timeout
    elseif not n then
        return false, nil, timeout
    end
    return self:flush()
end

--- write
--- @param str? string
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Response:write(str)
    self.replied = true
    local n, err, timeout = self.message:write(self.conn, str)
    if err then
        return false, errorf('failed to write()', err), timeout
    elseif not n then
        return false, nil, timeout
    end
    return self:flush()
end

--- write_json
--- @param res table
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Response:write_json(res)
    self.header:set('Content-Type', 'application/json')
    if not next(res) then
        -- empty json
        return self:write('{}')
    end

    local str, err = encode2json(res)
    if str then
        return self:write(str)
    end

    log.error('failed to encode response to JSON: %s', err)
    str = assert(encode2json({
        code = 500,
        status = code2reason(500),
    }))
    return self:write(str)
end

--- write_error
--- @param res table
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Response:write_error(res)
    if self.as_json then
        return self:write_json(res)
    end

    self.header:set('Content-Type', 'text/html')
    local str, err = self.refx:render_error_page(res.code, res)
    if str then
        return self:write(str)
    end

    log.error('failed to render error page: %s', err)
    return self:write(code2message(res.code) .. '\n')
end

--- write_redirection
--- @param res table
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Response:write_redirection(res)
    local location = res.location
    if type(location) ~= 'string' or #location == 0 or find(location, '%s') then
        fatalf('res.location must be non-empty string with no spaces')
    elseif res.code == 304 then
        -- 304 Not Modified
        self.header:set('Content-Location', location)
    else
        self.header:set('Location', location)
    end
    return self:write_error(res)
end

--- write_page
--- @param res table
--- @param page table
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Response:write_page(res, page)
    if self.refx:is_template(page.ext) then
        local str, err = self.refx:render_page(page.rpath, res)
        if str then
            self.header:set('Content-Type', page.mime)
            return self:write(str)
        end

        -- failed to render file
        log.error('failed to render template %q: %s', page.rpath, err)
        return self:internal_server_error()
    end

    return self:write_file(page.pathname)
end

--- write_response
--- @param code integer
--- @param res table
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Response:write_response(code, res)
    local ok, err = self.message:set_status(code)
    if not ok then
        fatalf('failed to set status code: %s', err)
    end

    res.code = code
    res.status = code2reason(code)
    if self.debug then
        local form = self.req:read_form()
        local sess = self.req:session(true)
        res.debug = {
            form = form and form.data,
            page = self.page,
            params = self.req.params,
            route_uri = self.req.route_uri,
            path = self.req.path,
            session = sess and sess.value,
        }
    end

    if code >= 400 then
        -- error response
        return self:write_error(res)
    elseif code >= 300 then
        -- redirection response
        return self:write_redirection(res)
    elseif self.as_json then
        -- json response
        return self:write_json(res)
    elseif self.page then
        -- page response
        return self:write_page(res, self.page)
    end
    -- no-content
    self.header:set('Content-Length', tostring(0))
    return self:write()
end

--- file
--- @param pathname string
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:file(pathname)
    if self.replied then
        fatalf('cannot send a response message twice')
    end

    -- save session automatically
    local _, err = self:save_session()
    if err then
        return self:internal_server_error(err)
    end

    -- file response
    self.message:set_status(200)
    return self:write_file(pathname)
end

--- reply
--- @param code integer
--- @param res table
--- @return boolean ok
--- @return any err
--- @return boolean? timeout
function Response:reply(code, res)
    if self.replied then
        fatalf('cannot send a response message twice')
    end

    -- save session automatically
    local _, err = self:save_session()
    if err then
        code = 500
        res = {
            error = errorf('failed to save_session()', err),
        }
    end

    return self:write_response(code, res)
end

--- merge
--- @param dst table
--- @param body table
--- @return table
local function merge(dst, body)
    if body == nil then
        return dst
    elseif type(body) ~= 'table' then
        fatalf('body must be table')
    elseif type(dst) ~= 'table' then
        dst = {}
    end

    for k, v in pairs(body) do
        if type(v) == 'table' then
            dst[k] = merge(dst[k], v)
        else
            dst[k] = v
        end
    end
    return dst
end

--- response1xx2xx
--- @param self reflex.response
--- @param code integer
--- @param data table
--- @return boolean ok
--- @return any err
--- @return boolean timeout
local function response1xx2xx(self, code, data)
    if self.body == nil then
        self.body = {}
    elseif type(self.body) ~= 'table' then
        fatalf('body must be table')
    end
    return self:reply(code, merge(self.body, data))
end

--- continue
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:continue(body)
    return response1xx2xx(self, 100, body)
end

--- switching_protocols
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:switching_protocols(body)
    return response1xx2xx(self, 101, body)
end

--- processing
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:processing(body)
    return response1xx2xx(self, 102, body)
end

--- ok
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:ok(body)
    return response1xx2xx(self, 200, body)
end

--- created
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:created(body)
    return response1xx2xx(self, 201, body)
end

--- accepted
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:accepted(body)
    return response1xx2xx(self, 202, body)
end

--- non_authoritative_information
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:non_authoritative_information(body)
    return response1xx2xx(self, 203, body)
end

--- no_content
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:no_content(body)
    return response1xx2xx(self, 204, body)
end

--- reset_content
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:reset_content(body)
    return response1xx2xx(self, 205, body)
end

--- partial_content
--- @param body table
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:partial_content(body)
    return response1xx2xx(self, 206, body)
end

--- multi_status
--- @param body table
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:multi_status(body)
    return response1xx2xx(self, 207, body)
end

--- already_reported
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:already_reported(body)
    return response1xx2xx(self, 208, body)
end

--- im_used
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:im_used(body)
    return response1xx2xx(self, 226, body)
end

--- multiple_choices
--- @param body table?
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:multiple_choices(body)
    return response1xx2xx(self, 300, body)
end

--- response3xx
--- @param self reflex.response
--- @param code integer
--- @param uri string
--- @return boolean ok
--- @return any err
--- @return boolean timeout
local function response3xx(self, code, uri)
    if type(uri) ~= 'string' or #uri == 0 or find(uri, '%s') then
        fatalf('uri must be non-empty string with no spaces')
    elseif self.body == nil then
        self.body = {}
    elseif type(self.body) ~= 'table' then
        fatalf('body must be table')
    end

    self.body.location = uri
    return self:reply(code, self.body)
end

--- moved_permanently
--- @param uri string
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:moved_permanently(uri)
    return response3xx(self, 301, uri)
end

--- found
--- @param uri string
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:found(uri)
    return response3xx(self, 302, uri)
end

--- see_other
--- @param uri string
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:see_other(uri)
    return response3xx(self, 303, uri)
end

--- not_modified
--- @param uri string
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:not_modified(uri)
    return response3xx(self, 304, uri)
end

--- use_proxy
--- @param uri string
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:use_proxy(uri)
    return response3xx(self, 305, uri)
end

--- temporary_redirect
--- @param uri string
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:temporary_redirect(uri)
    return response3xx(self, 307, uri)
end

--- permanent_redirect
--- @param uri string
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:permanent_redirect(uri)
    return response3xx(self, 308, uri)
end

--- response4xx5xx
--- @param self reflex.response
--- @param code integer
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
local function response4xx5xx(self, code, err)
    if self.body == nil then
        self.body = {}
    elseif type(self.body) ~= 'table' then
        fatalf('body must be table')
    end
    self.body.error = err
    return self:reply(code, self.body)
end

--- bad_request
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:bad_request(err)
    return response4xx5xx(self, 400, err)
end

--- unauthorized
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:unauthorized(err)
    return response4xx5xx(self, 401, err)
end

--- payment_required
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:payment_required(err)
    return response4xx5xx(self, 402, err)
end

--- forbidden
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:forbidden(err)
    return response4xx5xx(self, 403, err)
end

--- not_found
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:not_found(err)
    return response4xx5xx(self, 404, err)
end

--- method_not_allowed
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:method_not_allowed(err)
    return response4xx5xx(self, 405, err)
end

--- not_acceptable
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:not_acceptable(err)
    return response4xx5xx(self, 406, err)
end

--- proxy_authentication_required
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:proxy_authentication_required(err)
    return response4xx5xx(self, 407, err)
end

--- request_timeout
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:request_timeout(err)
    return response4xx5xx(self, 408, err)
end

--- conflict
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:conflict(err)
    return response4xx5xx(self, 409, err)
end

--- gone
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:gone(err)
    return response4xx5xx(self, 410, err)
end

--- length_required
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:length_required(err)
    return response4xx5xx(self, 411, err)
end

--- precondition_failed
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:precondition_failed(err)
    return response4xx5xx(self, 412, err)
end

--- payload_too_large
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:payload_too_large(err)
    return response4xx5xx(self, 413, err)
end

--- request_uri_too_long
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:request_uri_too_long(err)
    return response4xx5xx(self, 414, err)
end

--- unsupported_media_type
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:unsupported_media_type(err)
    return response4xx5xx(self, 415, err)
end

--- requested_range_not_satisfiable
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:requested_range_not_satisfiable(err)
    return response4xx5xx(self, 416, err)
end

--- expectation_failed
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:expectation_failed(err)
    return response4xx5xx(self, 417, err)
end

--- unprocessable_entity
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:unprocessable_entity(err)
    return response4xx5xx(self, 422, err)
end

--- locked
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:locked(err)
    return response4xx5xx(self, 423, err)
end

--- failed_dependency
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:failed_dependency(err)
    return response4xx5xx(self, 424, err)
end

--- upgrade_required
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:upgrade_required(err)
    return response4xx5xx(self, 426, err)
end

--- precondition_required
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:precondition_required(err)
    return response4xx5xx(self, 428, err)
end

--- too_many_requests
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:too_many_requests(err)
    return response4xx5xx(self, 429, err)
end

--- request_header_fields_too_large
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:request_header_fields_too_large(err)
    return response4xx5xx(self, 431, err)
end

--- unavailable_for_legal_reasons
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:unavailable_for_legal_reasons(err)
    return response4xx5xx(self, 451, err)
end

--- internal_server_error
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:internal_server_error(err)
    return response4xx5xx(self, 500, err)
end

--- not_implemented
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:not_implemented(err)
    return response4xx5xx(self, 501, err)
end

--- bad_gateway
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:bad_gateway(err)
    return response4xx5xx(self, 502, err)
end

--- service_unavailable
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:service_unavailable(err)
    return response4xx5xx(self, 503, err)
end

--- gateway_timeout
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:gateway_timeout(err)
    return response4xx5xx(self, 504, err)
end

--- http_version_not_supported
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:http_version_not_supported(err)
    return response4xx5xx(self, 505, err)
end

--- variant_also_negotiates
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:variant_also_negotiates(err)
    return response4xx5xx(self, 506, err)
end

--- insufficient_storage
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:insufficient_storage(err)
    return response4xx5xx(self, 507, err)
end

--- loop_detected
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:loop_detected(err)
    return response4xx5xx(self, 508, err)
end

--- not_extended
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:not_extended(err)
    return response4xx5xx(self, 510, err)
end

--- network_authentication_required
--- @param err any
--- @return boolean ok
--- @return any err
--- @return boolean timeout
function Response:network_authentication_required(err)
    return response4xx5xx(self, 511, err)
end

Response = require('metamodule').new(Response)

return Response


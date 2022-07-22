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
local isa = require('isa')
local is_boolean = isa.boolean
local is_table = isa.table
local is_string = isa.string
local new_response = require('net.http.message.response').new
local status2reason = require('reflex.status').code2reason

--- merge
--- @param dst any
--- @param src table
--- @return table
local function merge(dst, src)
    if not is_table(dst) then
        dst = {}
    end

    for k, v in pairs(src) do
        if is_table(v) then
            dst[k] = merge(dst[k], v)
        else
            dst[k] = v
        end
    end

    return dst
end

--- response1xx2xx
--- @param res reflex.response
--- @param code integer
--- @param body table
--- @param tomerge boolean
--- @return integer
local function response1xx2xx(res, code, body, tomerge)
    res:set_status(code)

    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 3)
        elseif tomerge == nil then
            res.body = body
        elseif not is_boolean(tomerge) then
            error('tomerge must be boolean', 3)
        elseif not tomerge then
            res.body = body
        else
            res.body = merge(res.body, body)
        end
    end

    res.status = code
    return code
end

--- response3xx
--- @param res reflex.response
--- @param code integer
--- @param uri string
--- @return integer
local function response3xx(res, code, uri)
    res:set_status(code)
    if not is_string(uri) or #uri == 0 or find(uri, '%s') then
        error('uri must be non-empty string with no spaces', 3)
    end
    res.header:set('Location', uri)
    res.status = code
    return code
end

--- response4xx5xx
--- @param res reflex.response
--- @param code integer
--- @param err any
--- @return integer
local function response4xx5xx(res, code, err)
    res:set_status(code)

    if not is_table(res.body) then
        res.body = {}
    end
    res.body.error = {
        code = code,
        status = status2reason(code),
        message = err,
    }
    res.status = code
    return code
end

--- @class reflex.response
--- @field conn net.http.connection
--- @field status integer
--- @field resp net.http.message.response
--- @field header net.http.header
--- @field body table
--- @field as_json boolean
local Response = {}

--- init
--- @param conn net.http.connection
--- @return reflex.response
function Response:init(conn)
    self.conn = conn
    self.resp = new_response()
    self.header = self.resp.header
    self.body = {}
    return self
end

--- set_status
---@param code integer
function Response:set_status(code)
    local ok, err = self.resp:set_status(code)
    if not ok then
        error(string.format('failed to set status code: %s', err), 2)
    end
    self.status = code
end

--- flush
--- @return integer n
--- @return string err
function Response:flush()
    return self.conn:flush()
end

--- write
--- @param msg any
--- @return integer n
--- @return string err
function Response:write(msg)
    if msg ~= nil and not is_string(msg) then
        error('msg must be string', 2)
    end
    return self.resp:write(self.conn, msg)
end

--- continue
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:continue(body, tomerge)
    return response1xx2xx(self, 100, body, tomerge)
end

--- switching_protocols
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:switching_protocols(body, tomerge)
    return response1xx2xx(self, 101, body, tomerge)
end

--- processing
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:processing(body, tomerge)
    return response1xx2xx(self, 102, body, tomerge)
end

--- ok
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:ok(body, tomerge)
    return response1xx2xx(self, 200, body, tomerge)
end

--- created
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:created(body, tomerge)
    return response1xx2xx(self, 201, body, tomerge)
end

--- accepted
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:accepted(body, tomerge)
    return response1xx2xx(self, 202, body, tomerge)
end

--- non_authoritative_information
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:non_authoritative_information(body, tomerge)
    return response1xx2xx(self, 203, body, tomerge)
end

--- no_content
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:no_content(body, tomerge)
    return response1xx2xx(self, 204, body, tomerge)
end

--- reset_content
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:reset_content(body, tomerge)
    return response1xx2xx(self, 205, body, tomerge)
end

--- partial_content
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:partial_content(body, tomerge)
    return response1xx2xx(self, 206, body, tomerge)
end

--- multi_status
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:multi_status(body, tomerge)
    return response1xx2xx(self, 207, body, tomerge)
end

--- already_reported
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:already_reported(body, tomerge)
    return response1xx2xx(self, 208, body, tomerge)
end

--- im_used
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:im_used(body, tomerge)
    return response1xx2xx(self, 226, body, tomerge)
end

--- multiple_choices
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:multiple_choices(body, tomerge)
    return response1xx2xx(self, 300, body, tomerge)
end

--- moved_permanently
--- @param uri string
--- @return integer
function Response:moved_permanently(uri)
    return response3xx(self, 301, uri)
end

--- found
--- @param uri string
--- @return integer
function Response:found(uri)
    return response3xx(self, 302, uri)
end

--- see_other
--- @param uri string
--- @return integer
function Response:see_other(uri)
    return response3xx(self, 303, uri)
end

--- not_modified
--- @param body table
--- @param tomerge boolean
--- @return integer
function Response:not_modified(body, tomerge)
    return response1xx2xx(self, 304, body, tomerge)
end

--- use_proxy
--- @param uri string
--- @return integer
function Response:use_proxy(uri)
    return response3xx(self, 305, uri)
end

--- temporary_redirect
--- @param uri string
--- @return integer
function Response:temporary_redirect(uri)
    return response3xx(self, 307, uri)
end

--- permanent_redirect
--- @param uri string
--- @return integer
function Response:permanent_redirect(uri)
    return response3xx(self, 308, uri)
end

--- bad_request
--- @param err any
--- @return integer
function Response:bad_request(err)
    return response4xx5xx(self, 400, err)
end

--- unauthorized
--- @param err any
--- @return integer
function Response:unauthorized(err)
    return response4xx5xx(self, 401, err)
end

--- payment_required
--- @param err any
--- @return integer
function Response:payment_required(err)
    return response4xx5xx(self, 402, err)
end

--- forbidden
--- @param err any
--- @return integer
function Response:forbidden(err)
    return response4xx5xx(self, 403, err)
end

--- not_found
--- @param err any
--- @return integer
function Response:not_found(err)
    return response4xx5xx(self, 404, err)
end

--- method_not_allowed
--- @param err any
--- @return integer
function Response:method_not_allowed(err)
    return response4xx5xx(self, 405, err)
end

--- not_acceptable
--- @param err any
--- @return integer
function Response:not_acceptable(err)
    return response4xx5xx(self, 406, err)
end

--- proxy_authentication_required
--- @param err any
--- @return integer
function Response:proxy_authentication_required(err)
    return response4xx5xx(self, 407, err)
end

--- request_timeout
--- @param err any
--- @return integer
function Response:request_timeout(err)
    return response4xx5xx(self, 408, err)
end

--- conflict
--- @param err any
--- @return integer
function Response:conflict(err)
    return response4xx5xx(self, 409, err)
end

--- gone
--- @param err any
--- @return integer
function Response:gone(err)
    return response4xx5xx(self, 410, err)
end

--- length_required
--- @param err any
--- @return integer
function Response:length_required(err)
    return response4xx5xx(self, 411, err)
end

--- precondition_failed
--- @param err any
--- @return integer
function Response:precondition_failed(err)
    return response4xx5xx(self, 412, err)
end

--- payload_too_large
--- @param err any
--- @return integer
function Response:payload_too_large(err)
    return response4xx5xx(self, 413, err)
end

--- request_uri_too_long
--- @param err any
--- @return integer
function Response:request_uri_too_long(err)
    return response4xx5xx(self, 414, err)
end

--- unsupported_media_type
--- @param err any
--- @return integer
function Response:unsupported_media_type(err)
    return response4xx5xx(self, 415, err)
end

--- requested_range_not_satisfiable
--- @param err any
--- @return integer
function Response:requested_range_not_satisfiable(err)
    return response4xx5xx(self, 416, err)
end

--- expectation_failed
--- @param err any
--- @return integer
function Response:expectation_failed(err)
    return response4xx5xx(self, 417, err)
end

--- unprocessable_entity
--- @param err any
--- @return integer
function Response:unprocessable_entity(err)
    return response4xx5xx(self, 422, err)
end

--- locked
--- @param err any
--- @return integer
function Response:locked(err)
    return response4xx5xx(self, 423, err)
end

--- failed_dependency
--- @param err any
--- @return integer
function Response:failed_dependency(err)
    return response4xx5xx(self, 424, err)
end

--- upgrade_required
--- @param err any
--- @return integer
function Response:upgrade_required(err)
    return response4xx5xx(self, 426, err)
end

--- precondition_required
--- @param err any
--- @return integer
function Response:precondition_required(err)
    return response4xx5xx(self, 428, err)
end

--- too_many_requests
--- @param err any
--- @return integer
function Response:too_many_requests(err)
    return response4xx5xx(self, 429, err)
end

--- request_header_fields_too_large
--- @param err any
--- @return integer
function Response:request_header_fields_too_large(err)
    return response4xx5xx(self, 431, err)
end

--- unavailable_for_legal_reasons
--- @param err any
--- @return integer
function Response:unavailable_for_legal_reasons(err)
    return response4xx5xx(self, 451, err)
end

--- internal_server_error
--- @param err any
--- @return integer
function Response:internal_server_error(err)
    return response4xx5xx(self, 500, err)
end

--- not_implemented
--- @param err any
--- @return integer
function Response:not_implemented(err)
    return response4xx5xx(self, 501, err)
end

--- bad_gateway
--- @param err any
--- @return integer
function Response:bad_gateway(err)
    return response4xx5xx(self, 502, err)
end

--- service_unavailable
--- @param err any
--- @return integer
function Response:service_unavailable(err)
    return response4xx5xx(self, 503, err)
end

--- gateway_timeout
--- @param err any
--- @return integer
function Response:gateway_timeout(err)
    return response4xx5xx(self, 504, err)
end

--- http_version_not_supported
--- @param err any
--- @return integer
function Response:http_version_not_supported(err)
    return response4xx5xx(self, 505, err)
end

--- variant_also_negotiates
--- @param err any
--- @return integer
function Response:variant_also_negotiates(err)
    return response4xx5xx(self, 506, err)
end

--- insufficient_storage
--- @param err any
--- @return integer
function Response:insufficient_storage(err)
    return response4xx5xx(self, 507, err)
end

--- loop_detected
--- @param err any
--- @return integer
function Response:loop_detected(err)
    return response4xx5xx(self, 508, err)
end

--- not_extended
--- @param err any
--- @return integer
function Response:not_extended(err)
    return response4xx5xx(self, 510, err)
end

--- network_authentication_required
--- @param err any
--- @return integer
function Response:network_authentication_required(err)
    return response4xx5xx(self, 511, err)
end

Response = require('metamodule').new(Response)

return Response


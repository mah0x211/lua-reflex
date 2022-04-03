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
local is_table = isa.table
local is_string = isa.string
local new_header = require('reflex.header').new
local status = require('reflex.status')

--- @class reflex.Response
--- @field header Header
--- @field body table
local Response = {}

--- init
--- @return reflex.Response
function Response:init()
    self.header = new_header()
    self.body = {}
    return self
end

--- continue
--- @param body table
--- @return integer
function Response:continue(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 100
    return 100
end

--- switching_protocols
--- @param body table
--- @return integer
function Response:switching_protocols(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 101
    return 101
end

--- processing
--- @param body table
--- @return integer
function Response:processing(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 102
    return 102
end

--- ok
--- @param body table
--- @return integer
function Response:ok(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 200
    return 200
end

--- created
--- @param body table
--- @return integer
function Response:created(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 201
    return 201
end

--- accepted
--- @param body table
--- @return integer
function Response:accepted(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 202
    return 202
end

--- non_authoritative_information
--- @param body table
--- @return integer
function Response:non_authoritative_information(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 203
    return 203
end

--- no_content
--- @param body table
--- @return integer
function Response:no_content(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 204
    return 204
end

--- reset_content
--- @param body table
--- @return integer
function Response:reset_content(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 205
    return 205
end

--- partial_content
--- @param body table
--- @return integer
function Response:partial_content(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 206
    return 206
end

--- multi_status
--- @param body table
--- @return integer
function Response:multi_status(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 207
    return 207
end

--- already_reported
--- @param body table
--- @return integer
function Response:already_reported(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 208
    return 208
end

--- im_used
--- @param body table
--- @return integer
function Response:im_used(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 226
    return 226
end

--- multiple_choices
--- @param body table
--- @return integer
function Response:multiple_choices(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 300
    return 300
end

--- moved_permanently
--- @param uri string
--- @return integer
function Response:moved_permanently(uri)
    if not is_string(uri) then
        error('uri must be string', 2)
    end
    self.header:set('Location', uri)
    self.status = 301
    return 301
end

--- found
--- @param uri string
--- @return integer
function Response:found(uri)
    if not is_string(uri) then
        error('uri must be string', 2)
    end
    self.header:set('Location', uri)
    self.status = 302
    return 302
end

--- see_other
--- @param uri string
--- @return integer
function Response:see_other(uri)
    if not is_string(uri) then
        error('uri must be string', 2)
    end
    self.header:set('Location', uri)
    self.status = 303
    return 303
end

--- not_modified
--- @param body table
--- @return integer
function Response:not_modified(body)
    if body ~= nil then
        if not is_table(body) then
            error('body must be table', 2)
        end
        self.body = body
    end
    self.status = 304
    return 304
end

--- use_proxy
--- @param uri string
--- @return integer
function Response:use_proxy(uri)
    if not is_string(uri) then
        error('uri must be string', 2)
    end
    self.header:set('Location', uri)
    self.status = 305
    return 305
end

--- temporary_redirect
--- @param uri string
--- @return integer
function Response:temporary_redirect(uri)
    if not is_string(uri) then
        error('uri must be string', 2)
    end
    self.header:set('Location', uri)
    self.status = 307
    return 307
end

--- permanent_redirect
--- @param uri string
--- @return integer
function Response:permanent_redirect(uri)
    if not is_string(uri) then
        error('uri must be string', 2)
    end
    self.header:set('Location', uri)
    self.status = 308
    return 308
end

--- bad_request
--- @param err any
--- @return integer
function Response:bad_request(err)
    if err == nil then
        err = status[400]
    end
    self.body.error = err
    self.status = 400
    return 400
end

--- unauthorized
--- @param err any
--- @return integer
function Response:unauthorized(err)
    if err == nil then
        err = status[401]
    end
    self.body.error = err
    self.status = 401
    return 401
end

--- payment_required
--- @param err any
--- @return integer
function Response:payment_required(err)
    if err == nil then
        err = status[402]
    end
    self.body.error = err
    self.status = 402
    return 402
end

--- forbidden
--- @param err any
--- @return integer
function Response:forbidden(err)
    if err == nil then
        err = status[403]
    end
    self.body.error = err
    self.status = 403
    return 403
end

--- not_found
--- @param err any
--- @return integer
function Response:not_found(err)
    if err == nil then
        err = status[404]
    end
    self.body.error = err
    self.status = 404
    return 404
end

--- method_not_allowed
--- @param err any
--- @return integer
function Response:method_not_allowed(err)
    if err == nil then
        err = status[405]
    end
    self.body.error = err
    self.status = 405
    return 405
end

--- not_acceptable
--- @param err any
--- @return integer
function Response:not_acceptable(err)
    if err == nil then
        err = status[406]
    end
    self.body.error = err
    self.status = 406
    return 406
end

--- proxy_authentication_required
--- @param err any
--- @return integer
function Response:proxy_authentication_required(err)
    if err == nil then
        err = status[407]
    end
    self.body.error = err
    self.status = 407
    return 407
end

--- request_timeout
--- @param err any
--- @return integer
function Response:request_timeout(err)
    if err == nil then
        err = status[408]
    end
    self.body.error = err
    self.status = 408
    return 408
end

--- conflict
--- @param err any
--- @return integer
function Response:conflict(err)
    if err == nil then
        err = status[409]
    end
    self.body.error = err
    self.status = 409
    return 409
end

--- gone
--- @param err any
--- @return integer
function Response:gone(err)
    if err == nil then
        err = status[410]
    end
    self.body.error = err
    self.status = 410
    return 410
end

--- length_required
--- @param err any
--- @return integer
function Response:length_required(err)
    if err == nil then
        err = status[411]
    end
    self.body.error = err
    self.status = 411
    return 411
end

--- precondition_failed
--- @param err any
--- @return integer
function Response:precondition_failed(err)
    if err == nil then
        err = status[412]
    end
    self.body.error = err
    self.status = 412
    return 412
end

--- request_entity_too_large
--- @param err any
--- @return integer
function Response:request_entity_too_large(err)
    if err == nil then
        err = status[413]
    end
    self.body.error = err
    self.status = 413
    return 413
end

--- request_uri_too_long
--- @param err any
--- @return integer
function Response:request_uri_too_long(err)
    if err == nil then
        err = status[414]
    end
    self.body.error = err
    self.status = 414
    return 414
end

--- unsupported_media_type
--- @param err any
--- @return integer
function Response:unsupported_media_type(err)
    if err == nil then
        err = status[415]
    end
    self.body.error = err
    self.status = 415
    return 415
end

--- requested_range_not_satisfiable
--- @param err any
--- @return integer
function Response:requested_range_not_satisfiable(err)
    if err == nil then
        err = status[416]
    end
    self.body.error = err
    self.status = 416
    return 416
end

--- expectation_failed
--- @param err any
--- @return integer
function Response:expectation_failed(err)
    if err == nil then
        err = status[417]
    end
    self.body.error = err
    self.status = 417
    return 417
end

--- unprocessable_entity
--- @param err any
--- @return integer
function Response:unprocessable_entity(err)
    if err == nil then
        err = status[422]
    end
    self.body.error = err
    self.status = 422
    return 422
end

--- locked
--- @param err any
--- @return integer
function Response:locked(err)
    if err == nil then
        err = status[423]
    end
    self.body.error = err
    self.status = 423
    return 423
end

--- failed_dependency
--- @param err any
--- @return integer
function Response:failed_dependency(err)
    if err == nil then
        err = status[424]
    end
    self.body.error = err
    self.status = 424
    return 424
end

--- upgrade_required
--- @param err any
--- @return integer
function Response:upgrade_required(err)
    if err == nil then
        err = status[426]
    end
    self.body.error = err
    self.status = 426
    return 426
end

--- precondition_required
--- @param err any
--- @return integer
function Response:precondition_required(err)
    if err == nil then
        err = status[428]
    end
    self.body.error = err
    self.status = 428
    return 428
end

--- too_many_requests
--- @param err any
--- @return integer
function Response:too_many_requests(err)
    if err == nil then
        err = status[429]
    end
    self.body.error = err
    self.status = 429
    return 429
end

--- request_header_fields_too_large
--- @param err any
--- @return integer
function Response:request_header_fields_too_large(err)
    if err == nil then
        err = status[431]
    end
    self.body.error = err
    self.status = 431
    return 431
end

--- unavailable_for_legal_reasons
--- @param err any
--- @return integer
function Response:unavailable_for_legal_reasons(err)
    if err == nil then
        err = status[451]
    end
    self.body.error = err
    self.status = 451
    return 451
end

--- internal_server_error
--- @param err any
--- @return integer
function Response:internal_server_error(err)
    if err == nil then
        err = status[500]
    end
    self.body.error = err
    self.status = 500
    return 500
end

--- not_implemented
--- @param err any
--- @return integer
function Response:not_implemented(err)
    if err == nil then
        err = status[501]
    end
    self.body.error = err
    self.status = 501
    return 501
end

--- bad_gateway
--- @param err any
--- @return integer
function Response:bad_gateway(err)
    if err == nil then
        err = status[502]
    end
    self.body.error = err
    self.status = 502
    return 502
end

--- service_unavailable
--- @param err any
--- @return integer
function Response:service_unavailable(err)
    if err == nil then
        err = status[503]
    end
    self.body.error = err
    self.status = 503
    return 503
end

--- gateway_timeout
--- @param err any
--- @return integer
function Response:gateway_timeout(err)
    if err == nil then
        err = status[504]
    end
    self.body.error = err
    self.status = 504
    return 504
end

--- http_version_not_supported
--- @param err any
--- @return integer
function Response:http_version_not_supported(err)
    if err == nil then
        err = status[505]
    end
    self.body.error = err
    self.status = 505
    return 505
end

--- variant_also_negotiates
--- @param err any
--- @return integer
function Response:variant_also_negotiates(err)
    if err == nil then
        err = status[506]
    end
    self.body.error = err
    self.status = 506
    return 506
end

--- insufficient_storage
--- @param err any
--- @return integer
function Response:insufficient_storage(err)
    if err == nil then
        err = status[507]
    end
    self.body.error = err
    self.status = 507
    return 507
end

--- loop_detected
--- @param err any
--- @return integer
function Response:loop_detected(err)
    if err == nil then
        err = status[508]
    end
    self.body.error = err
    self.status = 508
    return 508
end

--- not_extended
--- @param err any
--- @return integer
function Response:not_extended(err)
    if err == nil then
        err = status[510]
    end
    self.body.error = err
    self.status = 510
    return 510
end

--- network_authentication_required
--- @param err any
--- @return integer
function Response:network_authentication_required(err)
    if err == nil then
        err = status[511]
    end
    self.body.error = err
    self.status = 511
    return 511
end

return {
    new = require('metamodule').new(Response),
}


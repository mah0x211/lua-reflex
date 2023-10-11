require('luacov')
local testcase = require('testcase')
local verify_token = require('reflex.token').verify
local new_response = require('reflex.response')

function testcase.new()
    -- test that create new Response
    local res = assert(new_response())
    assert.match(res, '^reflex%.response: ', false)
end

function testcase.no_keepalive()
    local res = new_response()
    assert.is_true(res:is_keepalive())
    assert.not_contains(res.header:get('Connection', true) or {}, 'close')

    -- test that set no keepalive response
    res:no_keepalive()
    assert.is_false(res:is_keepalive())
    assert.contains(res.header:get('Connection', true), 'close')
end

function testcase.json()
    -- test that set enable json response
    local res = new_response()
    assert.is_false(res:is_json())
    assert.equal(res:json(), res)
    assert.is_true(res:is_json())
end

function testcase.set_csrf_cookie()
    -- test that set csrf cookie
    local res = new_response()
    res:set_csrf_cookie()
    local cookie = res.header:get('Set-Cookie')
    assert.match(cookie, 'X%-CSRF%-Token=.*; HttpOnly', false)
    -- confirm that csrf token is valid
    local token = string.match(cookie, '[^=]=([^;]*);')
    assert.is_true(verify_token('X-CSRF-Token', token))

    -- test that throws an error if httponly argument is not boolean
    local err = assert.throws(res.set_csrf_cookie, res, 'foo')
    assert.match(err, 'httponly must be boolean')
end

function testcase.response1xx2xx()
    local msg
    local res = new_response()
    res.reply = function(_, code, data)
        msg = data
        msg.code = code
    end

    for _, v in ipairs({
        {
            name = 'continue',
            code = 100,
        },
        {
            name = 'switching_protocols',
            code = 101,
        },
        {
            name = 'processing',
            code = 102,
        },
        {
            name = 'ok',
            code = 200,
        },
        {
            name = 'created',
            code = 201,
        },
        {
            name = 'accepted',
            code = 202,
        },
        {
            name = 'non_authoritative_information',
            code = 203,
        },
        {
            name = 'no_content',
            code = 204,
        },
        {
            name = 'reset_content',
            code = 205,
        },
        {
            name = 'partial_content',
            code = 206,
        },
        {
            name = 'multi_status',
            code = 207,
        },
        {
            name = 'already_reported',
            code = 208,
        },
        {
            name = 'im_used',
            code = 226,
        },
        {
            name = 'multiple_choices',
            code = 300,
        },
    }) do
        local method = res[v.name]
        method(res)
        assert.equal(msg, {
            code = v.code,
        })

        -- test that set body
        method(res, {
            foo = 'bar',
        })
        assert.equal(msg, {
            code = v.code,
            foo = 'bar',
        })
        -- test that merge body
        res.body = {
            hello = 'world',
        }
        method(res, {
            foo = 'bar',
        })
        assert.equal(msg, {
            code = v.code,
            foo = 'bar',
            hello = 'world',
        })
        res.body = nil

        -- test that throws an error if body is not table
        local err = assert.throws(method, res, 1)
        assert.match(err, 'body must be table')
    end
end

function testcase.response3xx()
    local msg
    local res = new_response()
    res.reply = function(_, code, data)
        msg = data
        msg.code = code
    end

    for _, v in ipairs({
        {
            name = 'moved_permanently',
            code = 301,
        },
        {
            name = 'found',
            code = 302,
        },
        {
            name = 'see_other',
            code = 303,
        },
        {
            name = 'not_modified',
            code = 304,
        },
        {
            name = 'use_proxy',
            code = 305,
        },
        {
            name = 'temporary_redirect',
            code = 307,
        },
        {
            name = 'permanent_redirect',
            code = 308,
        },
    }) do
        local method = res[v.name]
        local uri = 'foo/bar'
        method(res, uri)
        assert.equal(msg, {
            code = v.code,
            location = uri,
        })

        -- test that throws an error if uri is not string
        local err = assert.throws(method, res, 1)
        assert.match(err, 'uri must be non-empty string')
    end
end

function testcase.response4xx5xx()
    local msg
    local res = new_response()
    res.reply = function(_, code, data)
        msg = data
        msg.code = code
    end

    for _, v in ipairs({
        -- 4XX status
        {
            name = 'bad_request',
            code = 400,
        },
        {
            name = 'unauthorized',
            code = 401,
        },
        {
            name = 'payment_required',
            code = 402,
        },
        {
            name = 'forbidden',
            code = 403,
        },
        {
            name = 'not_found',
            code = 404,
        },
        {
            name = 'method_not_allowed',
            code = 405,
        },
        {
            name = 'not_acceptable',
            code = 406,
        },
        {
            name = 'proxy_authentication_required',
            code = 407,
        },
        {
            name = 'request_timeout',
            code = 408,
        },
        {
            name = 'conflict',
            code = 409,
        },
        {
            name = 'gone',
            code = 410,
        },
        {
            name = 'length_required',
            code = 411,
        },
        {
            name = 'precondition_failed',
            code = 412,
        },
        {
            name = 'payload_too_large',
            code = 413,
        },
        {
            name = 'request_uri_too_long',
            code = 414,
        },
        {
            name = 'unsupported_media_type',
            code = 415,
        },
        {
            name = 'requested_range_not_satisfiable',
            code = 416,
        },
        {
            name = 'expectation_failed',
            code = 417,
        },
        {
            name = 'unprocessable_entity',
            code = 422,
        },
        {
            name = 'locked',
            code = 423,
        },
        {
            name = 'failed_dependency',
            code = 424,
        },
        {
            name = 'upgrade_required',
            code = 426,
        },
        {
            name = 'precondition_required',
            code = 428,
        },
        {
            name = 'too_many_requests',
            code = 429,
        },
        {
            name = 'request_header_fields_too_large',
            code = 431,
        },
        {
            name = 'unavailable_for_legal_reasons',
            code = 451,
        },
        -- 5XX status
        {
            name = 'internal_server_error',
            code = 500,
        },
        {
            name = 'not_implemented',
            code = 501,
        },
        {
            name = 'bad_gateway',
            code = 502,
        },
        {
            name = 'service_unavailable',
            code = 503,
        },
        {
            name = 'gateway_timeout',
            code = 504,
        },
        {
            name = 'http_version_not_supported',
            code = 505,
        },
        {
            name = 'variant_also_negotiates',
            code = 506,
        },
        {
            name = 'insufficient_storage',
            code = 507,
        },
        {
            name = 'loop_detected',
            code = 508,
        },
        {
            name = 'not_extended',
            code = 510,
        },
        {
            name = 'network_authentication_required',
            code = 511,
        },
    }) do
        res.body = nil
        local method = res[v.name]
        method(res)
        assert.equal(msg, {
            code = v.code,
        })

        -- test that set body
        method(res, {
            foo = 'bar',
        })
        assert.equal(msg, {
            code = v.code,
            error = {
                foo = 'bar',
            },
        })
        -- test that merge body
        res.body = {
            hello = 'world',
        }
        method(res, {
            foo = 'bar',
        })
        assert.equal(msg, {
            code = v.code,
            hello = 'world',
            error = {
                foo = 'bar',
            },
        })
    end
end


require('luacov')
local testcase = require('testcase')
local status = require('reflex.status')
local response = require('reflex.response')

function testcase.new()
    -- test that create new Response
    local res = assert(response.new())
    assert.match(res, '^reflex%.response: ', false)
end

function testcase.continue()
    local res = assert(response.new())

    -- test that returns 100
    assert.equal(res:continue(), 100)
    assert.equal(res.status, 100)

    -- test that set body
    assert.equal(res:continue({
        foo = 'bar',
    }), 100)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.continue, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.switching_protocols()
    local res = assert(response.new())

    -- test that returns 101
    assert.equal(res:switching_protocols(), 101)
    assert.equal(res.status, 101)

    -- test that set body
    assert.equal(res:switching_protocols({
        foo = 'bar',
    }), 101)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.switching_protocols, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.processing()
    local res = assert(response.new())

    -- test that returns 102
    assert.equal(res:processing(), 102)
    assert.equal(res.status, 102)

    -- test that set body
    assert.equal(res:processing({
        foo = 'bar',
    }), 102)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.processing, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.ok()
    local res = assert(response.new())

    -- test that returns 200
    assert.equal(res:ok(), 200)
    assert.equal(res.status, 200)

    -- test that set body
    assert.equal(res:ok({
        foo = 'bar',
    }), 200)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.ok, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.created()
    local res = assert(response.new())

    -- test that returns 201
    assert.equal(res:created(), 201)
    assert.equal(res.status, 201)

    -- test that set body
    assert.equal(res:created({
        foo = 'bar',
    }), 201)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.created, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.accepted()
    local res = assert(response.new())

    -- test that returns 202
    assert.equal(res:accepted(), 202)
    assert.equal(res.status, 202)

    -- test that set body
    assert.equal(res:accepted({
        foo = 'bar',
    }), 202)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.accepted, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.non_authoritative_information()
    local res = assert(response.new())

    -- test that returns 203
    assert.equal(res:non_authoritative_information(), 203)
    assert.equal(res.status, 203)

    -- test that set body
    assert.equal(res:non_authoritative_information({
        foo = 'bar',
    }), 203)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.non_authoritative_information, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.no_content()
    local res = assert(response.new())

    -- test that returns 204
    assert.equal(res:no_content(), 204)
    assert.equal(res.status, 204)

    -- test that set body
    assert.equal(res:no_content({
        foo = 'bar',
    }), 204)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.no_content, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.reset_content()
    local res = assert(response.new())

    -- test that returns 205
    assert.equal(res:reset_content(), 205)
    assert.equal(res.status, 205)

    -- test that set body
    assert.equal(res:reset_content({
        foo = 'bar',
    }), 205)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.reset_content, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.partial_content()
    local res = assert(response.new())

    -- test that returns 206
    assert.equal(res:partial_content(), 206)
    assert.equal(res.status, 206)

    -- test that set body
    assert.equal(res:partial_content({
        foo = 'bar',
    }), 206)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.partial_content, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.multi_status()
    local res = assert(response.new())

    -- test that returns 207
    assert.equal(res:multi_status(), 207)
    assert.equal(res.status, 207)

    -- test that set body
    assert.equal(res:multi_status({
        foo = 'bar',
    }), 207)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.multi_status, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.already_reported()
    local res = assert(response.new())

    -- test that returns 208
    assert.equal(res:already_reported(), 208)
    assert.equal(res.status, 208)

    -- test that set body
    assert.equal(res:already_reported({
        foo = 'bar',
    }), 208)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.already_reported, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.im_used()
    local res = assert(response.new())

    -- test that returns 226
    assert.equal(res:im_used(), 226)
    assert.equal(res.status, 226)

    -- test that set body
    assert.equal(res:im_used({
        foo = 'bar',
    }), 226)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.im_used, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.multiple_choices()
    local res = assert(response.new())

    -- test that returns 300
    assert.equal(res:multiple_choices(), 300)
    assert.equal(res.status, 300)

    -- test that set body
    assert.equal(res:multiple_choices({
        foo = 'bar',
    }), 300)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.multiple_choices, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.moved_permanently()
    local res = assert(response.new())

    -- test that returns 301
    assert.equal(res:moved_permanently('/foo/bar'), 301)
    assert.equal(res.status, 301)
    assert.equal(res.header:get('Location'), {
        '/foo/bar',
    })

    -- test that throws an error if uri is empty-string
    local err = assert.throws(res.moved_permanently, res, ' \n \t ')
    assert.match(err, 'uri must be non-empty string with no spaces')

    -- test that throws an error if uri is not string
    err = assert.throws(res.moved_permanently, res, 1)
    assert.match(err, 'uri must be non-empty string with no spaces')
end

function testcase.found()
    local res = assert(response.new())

    -- test that returns 302
    assert.equal(res:found('/foo/bar'), 302)
    assert.equal(res.status, 302)
    assert.equal(res.header:get('Location'), {
        '/foo/bar',
    })

    -- test that throws an error if uri is empty-string
    local err = assert.throws(res.found, res, ' \n \t ')
    assert.match(err, 'uri must be non-empty string with no spaces')

    -- test that throws an error if uri is not string
    err = assert.throws(res.found, res, 1)
    assert.match(err, 'uri must be non-empty string with no spaces')
end

function testcase.see_other()
    local res = assert(response.new())

    -- test that returns 303
    assert.equal(res:see_other('/foo/bar'), 303)
    assert.equal(res.status, 303)
    assert.equal(res.header:get('Location'), {
        '/foo/bar',
    })

    -- test that throws an error if uri is empty-string
    local err = assert.throws(res.see_other, res, ' \n \t ')
    assert.match(err, 'uri must be non-empty string with no spaces')

    -- test that throws an error if uri is not string
    err = assert.throws(res.see_other, res, 1)
    assert.match(err, 'uri must be non-empty string with no spaces')
end

function testcase.not_modified()
    local res = assert(response.new())

    -- test that returns 304
    assert.equal(res:not_modified(), 304)
    assert.equal(res.status, 304)

    -- test that set body
    assert.equal(res:not_modified({
        foo = 'bar',
    }), 304)
    assert.equal(res.body, {
        foo = 'bar',
    })

    -- test that throws an error if body is not table
    local err = assert.throws(res.not_modified, res, 1)
    assert.match(err, 'body must be table')
end

function testcase.use_proxy()
    local res = assert(response.new())

    -- test that returns 305
    assert.equal(res:use_proxy('/foo/bar'), 305)
    assert.equal(res.status, 305)
    assert.equal(res.header:get('Location'), {
        '/foo/bar',
    })

    -- test that throws an error if uri is empty-string
    local err = assert.throws(res.use_proxy, res, ' \n \t ')
    assert.match(err, 'uri must be non-empty string with no spaces')

    -- test that throws an error if uri is not string
    err = assert.throws(res.use_proxy, res, 1)
    assert.match(err, 'uri must be non-empty string with no spaces')
end

function testcase.temporary_redirect()
    local res = assert(response.new())

    -- test that returns 307
    assert.equal(res:temporary_redirect('/foo/bar'), 307)
    assert.equal(res.status, 307)
    assert.equal(res.header:get('Location'), {
        '/foo/bar',
    })

    -- test that throws an error if uri is empty-string
    local err = assert.throws(res.temporary_redirect, res, ' \n \t ')
    assert.match(err, 'uri must be non-empty string with no spaces')

    -- test that throws an error if uri is not string
    err = assert.throws(res.temporary_redirect, res, 1)
    assert.match(err, 'uri must be non-empty string with no spaces')
end

function testcase.permanent_redirect()
    local res = assert(response.new())

    -- test that returns 308
    assert.equal(res:permanent_redirect('/foo/bar'), 308)
    assert.equal(res.status, 308)
    assert.equal(res.header:get('Location'), {
        '/foo/bar',
    })

    -- test that throws an error if uri is empty-string
    local err = assert.throws(res.permanent_redirect, res, ' \n \t ')
    assert.match(err, 'uri must be non-empty string with no spaces')

    -- test that throws an error if uri is not string
    err = assert.throws(res.permanent_redirect, res, 1)
    assert.match(err, 'uri must be non-empty string with no spaces')
end

function testcase.bad_request()
    local res = assert(response.new())

    -- test that returns 400
    assert.equal(res:bad_request(), 400)
    assert.equal(res.status, 400)
    assert.equal(res.body.error, status[400])

    -- test that set value to body.error field
    assert.equal(res:bad_request('hello'), 400)
    assert.equal(res.status, 400)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.unauthorized()
    local res = assert(response.new())

    -- test that returns 401
    assert.equal(res:unauthorized(), 401)
    assert.equal(res.status, 401)
    assert.equal(res.body.error, status[401])

    -- test that set value to body.error field
    assert.equal(res:unauthorized('hello'), 401)
    assert.equal(res.status, 401)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.payment_required()
    local res = assert(response.new())

    -- test that returns 402
    assert.equal(res:payment_required(), 402)
    assert.equal(res.status, 402)
    assert.equal(res.body.error, status[402])

    -- test that set value to body.error field
    assert.equal(res:payment_required('hello'), 402)
    assert.equal(res.status, 402)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.forbidden()
    local res = assert(response.new())

    -- test that returns 403
    assert.equal(res:forbidden(), 403)
    assert.equal(res.status, 403)
    assert.equal(res.body.error, status[403])

    -- test that set value to body.error field
    assert.equal(res:forbidden('hello'), 403)
    assert.equal(res.status, 403)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.not_found()
    local res = assert(response.new())

    -- test that returns 404
    assert.equal(res:not_found(), 404)
    assert.equal(res.status, 404)
    assert.equal(res.body.error, status[404])

    -- test that set value to body.error field
    assert.equal(res:not_found('hello'), 404)
    assert.equal(res.status, 404)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.method_not_allowed()
    local res = assert(response.new())

    -- test that returns 405
    assert.equal(res:method_not_allowed(), 405)
    assert.equal(res.status, 405)
    assert.equal(res.body.error, status[405])

    -- test that set value to body.error field
    assert.equal(res:method_not_allowed('hello'), 405)
    assert.equal(res.status, 405)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.not_acceptable()
    local res = assert(response.new())

    -- test that returns 406
    assert.equal(res:not_acceptable(), 406)
    assert.equal(res.status, 406)
    assert.equal(res.body.error, status[406])

    -- test that set value to body.error field
    assert.equal(res:not_acceptable('hello'), 406)
    assert.equal(res.status, 406)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.proxy_authentication_required()
    local res = assert(response.new())

    -- test that returns 407
    assert.equal(res:proxy_authentication_required(), 407)
    assert.equal(res.status, 407)
    assert.equal(res.body.error, status[407])

    -- test that set value to body.error field
    assert.equal(res:proxy_authentication_required('hello'), 407)
    assert.equal(res.status, 407)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.request_timeout()
    local res = assert(response.new())

    -- test that returns 408
    assert.equal(res:request_timeout(), 408)
    assert.equal(res.status, 408)
    assert.equal(res.body.error, status[408])

    -- test that set value to body.error field
    assert.equal(res:request_timeout('hello'), 408)
    assert.equal(res.status, 408)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.conflict()
    local res = assert(response.new())

    -- test that returns 409
    assert.equal(res:conflict(), 409)
    assert.equal(res.status, 409)
    assert.equal(res.body.error, status[409])

    -- test that set value to body.error field
    assert.equal(res:conflict('hello'), 409)
    assert.equal(res.status, 409)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.gone()
    local res = assert(response.new())

    -- test that returns 410
    assert.equal(res:gone(), 410)
    assert.equal(res.status, 410)
    assert.equal(res.body.error, status[410])

    -- test that set value to body.error field
    assert.equal(res:gone('hello'), 410)
    assert.equal(res.status, 410)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.length_required()
    local res = assert(response.new())

    -- test that returns 411
    assert.equal(res:length_required(), 411)
    assert.equal(res.status, 411)
    assert.equal(res.body.error, status[411])

    -- test that set value to body.error field
    assert.equal(res:length_required('hello'), 411)
    assert.equal(res.status, 411)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.precondition_failed()
    local res = assert(response.new())

    -- test that returns 412
    assert.equal(res:precondition_failed(), 412)
    assert.equal(res.status, 412)
    assert.equal(res.body.error, status[412])

    -- test that set value to body.error field
    assert.equal(res:precondition_failed('hello'), 412)
    assert.equal(res.status, 412)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.request_entity_too_large()
    local res = assert(response.new())

    -- test that returns 413
    assert.equal(res:request_entity_too_large(), 413)
    assert.equal(res.status, 413)
    assert.equal(res.body.error, status[413])

    -- test that set value to body.error field
    assert.equal(res:request_entity_too_large('hello'), 413)
    assert.equal(res.status, 413)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.request_uri_too_long()
    local res = assert(response.new())

    -- test that returns 414
    assert.equal(res:request_uri_too_long(), 414)
    assert.equal(res.status, 414)
    assert.equal(res.body.error, status[414])

    -- test that set value to body.error field
    assert.equal(res:request_uri_too_long('hello'), 414)
    assert.equal(res.status, 414)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.unsupported_media_type()
    local res = assert(response.new())

    -- test that returns 415
    assert.equal(res:unsupported_media_type(), 415)
    assert.equal(res.status, 415)
    assert.equal(res.body.error, status[415])

    -- test that set value to body.error field
    assert.equal(res:unsupported_media_type('hello'), 415)
    assert.equal(res.status, 415)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.requested_range_not_satisfiable()
    local res = assert(response.new())

    -- test that returns 416
    assert.equal(res:requested_range_not_satisfiable(), 416)
    assert.equal(res.status, 416)
    assert.equal(res.body.error, status[416])

    -- test that set value to body.error field
    assert.equal(res:requested_range_not_satisfiable('hello'), 416)
    assert.equal(res.status, 416)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.expectation_failed()
    local res = assert(response.new())

    -- test that returns 417
    assert.equal(res:expectation_failed(), 417)
    assert.equal(res.status, 417)
    assert.equal(res.body.error, status[417])

    -- test that set value to body.error field
    assert.equal(res:expectation_failed('hello'), 417)
    assert.equal(res.status, 417)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.unprocessable_entity()
    local res = assert(response.new())

    -- test that returns 422
    assert.equal(res:unprocessable_entity(), 422)
    assert.equal(res.status, 422)
    assert.equal(res.body.error, status[422])

    -- test that set value to body.error field
    assert.equal(res:unprocessable_entity('hello'), 422)
    assert.equal(res.status, 422)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.locked()
    local res = assert(response.new())

    -- test that returns 423
    assert.equal(res:locked(), 423)
    assert.equal(res.status, 423)
    assert.equal(res.body.error, status[423])

    -- test that set value to body.error field
    assert.equal(res:locked('hello'), 423)
    assert.equal(res.status, 423)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.failed_dependency()
    local res = assert(response.new())

    -- test that returns 424
    assert.equal(res:failed_dependency(), 424)
    assert.equal(res.status, 424)
    assert.equal(res.body.error, status[424])

    -- test that set value to body.error field
    assert.equal(res:failed_dependency('hello'), 424)
    assert.equal(res.status, 424)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.upgrade_required()
    local res = assert(response.new())

    -- test that returns 426
    assert.equal(res:upgrade_required(), 426)
    assert.equal(res.status, 426)
    assert.equal(res.body.error, status[426])

    -- test that set value to body.error field
    assert.equal(res:upgrade_required('hello'), 426)
    assert.equal(res.status, 426)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.precondition_required()
    local res = assert(response.new())

    -- test that returns 428
    assert.equal(res:precondition_required(), 428)
    assert.equal(res.status, 428)
    assert.equal(res.body.error, status[428])

    -- test that set value to body.error field
    assert.equal(res:precondition_required('hello'), 428)
    assert.equal(res.status, 428)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.too_many_requests()
    local res = assert(response.new())

    -- test that returns 429
    assert.equal(res:too_many_requests(), 429)
    assert.equal(res.status, 429)
    assert.equal(res.body.error, status[429])

    -- test that set value to body.error field
    assert.equal(res:too_many_requests('hello'), 429)
    assert.equal(res.status, 429)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.request_header_fields_too_large()
    local res = assert(response.new())

    -- test that returns 431
    assert.equal(res:request_header_fields_too_large(), 431)
    assert.equal(res.status, 431)
    assert.equal(res.body.error, status[431])

    -- test that set value to body.error field
    assert.equal(res:request_header_fields_too_large('hello'), 431)
    assert.equal(res.status, 431)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.unavailable_for_legal_reasons()
    local res = assert(response.new())

    -- test that returns 451
    assert.equal(res:unavailable_for_legal_reasons(), 451)
    assert.equal(res.status, 451)
    assert.equal(res.body.error, status[451])

    -- test that set value to body.error field
    assert.equal(res:unavailable_for_legal_reasons('hello'), 451)
    assert.equal(res.status, 451)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.internal_server_error()
    local res = assert(response.new())

    -- test that returns 500
    assert.equal(res:internal_server_error(), 500)
    assert.equal(res.status, 500)
    assert.equal(res.body.error, status[500])

    -- test that set value to body.error field
    assert.equal(res:internal_server_error('hello'), 500)
    assert.equal(res.status, 500)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.not_implemented()
    local res = assert(response.new())

    -- test that returns 501
    assert.equal(res:not_implemented(), 501)
    assert.equal(res.status, 501)
    assert.equal(res.body.error, status[501])

    -- test that set value to body.error field
    assert.equal(res:not_implemented('hello'), 501)
    assert.equal(res.status, 501)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.bad_gateway()
    local res = assert(response.new())

    -- test that returns 502
    assert.equal(res:bad_gateway(), 502)
    assert.equal(res.status, 502)
    assert.equal(res.body.error, status[502])

    -- test that set value to body.error field
    assert.equal(res:bad_gateway('hello'), 502)
    assert.equal(res.status, 502)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.service_unavailable()
    local res = assert(response.new())

    -- test that returns 503
    assert.equal(res:service_unavailable(), 503)
    assert.equal(res.status, 503)
    assert.equal(res.body.error, status[503])

    -- test that set value to body.error field
    assert.equal(res:service_unavailable('hello'), 503)
    assert.equal(res.status, 503)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.gateway_timeout()
    local res = assert(response.new())

    -- test that returns 504
    assert.equal(res:gateway_timeout(), 504)
    assert.equal(res.status, 504)
    assert.equal(res.body.error, status[504])

    -- test that set value to body.error field
    assert.equal(res:gateway_timeout('hello'), 504)
    assert.equal(res.status, 504)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.http_version_not_supported()
    local res = assert(response.new())

    -- test that returns 505
    assert.equal(res:http_version_not_supported(), 505)
    assert.equal(res.status, 505)
    assert.equal(res.body.error, status[505])

    -- test that set value to body.error field
    assert.equal(res:http_version_not_supported('hello'), 505)
    assert.equal(res.status, 505)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.variant_also_negotiates()
    local res = assert(response.new())

    -- test that returns 506
    assert.equal(res:variant_also_negotiates(), 506)
    assert.equal(res.status, 506)
    assert.equal(res.body.error, status[506])

    -- test that set value to body.error field
    assert.equal(res:variant_also_negotiates('hello'), 506)
    assert.equal(res.status, 506)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.insufficient_storage()
    local res = assert(response.new())

    -- test that returns 507
    assert.equal(res:insufficient_storage(), 507)
    assert.equal(res.status, 507)
    assert.equal(res.body.error, status[507])

    -- test that set value to body.error field
    assert.equal(res:insufficient_storage('hello'), 507)
    assert.equal(res.status, 507)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.loop_detected()
    local res = assert(response.new())

    -- test that returns 508
    assert.equal(res:loop_detected(), 508)
    assert.equal(res.status, 508)
    assert.equal(res.body.error, status[508])

    -- test that set value to body.error field
    assert.equal(res:loop_detected('hello'), 508)
    assert.equal(res.status, 508)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.not_extended()
    local res = assert(response.new())

    -- test that returns 510
    assert.equal(res:not_extended(), 510)
    assert.equal(res.status, 510)
    assert.equal(res.body.error, status[510])

    -- test that set value to body.error field
    assert.equal(res:not_extended('hello'), 510)
    assert.equal(res.status, 510)
    assert.equal(res.body, {
        error = 'hello',
    })
end

function testcase.network_authentication_required()
    local res = assert(response.new())

    -- test that returns 511
    assert.equal(res:network_authentication_required(), 511)
    assert.equal(res.status, 511)
    assert.equal(res.body.error, status[511])

    -- test that set value to body.error field
    assert.equal(res:network_authentication_required('hello'), 511)
    assert.equal(res.status, 511)
    assert.equal(res.body, {
        error = 'hello',
    })
end


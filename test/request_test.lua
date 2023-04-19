require('luacov')
local testcase = require('testcase')
local new_http_request = require('net.http.message.request').new
local generate_token = require('reflex.token').generate
local new_request = require('reflex.request')

function testcase.new()
    -- test that create a new request
    local req = new_http_request()
    assert(req:set_uri('.dot-file'))
    local r = assert(new_request(req))
    assert.match(r, '^reflex%.request: ', false)
end

function testcase.parse_cookies()
    -- test that parse cookies
    local r = new_request(new_http_request())
    assert(r.header:set('Cookie', 'foo=bar; baz=qux'))
    r:parse_cookies()
    assert.equal(r.cookies, {
        foo = 'bar',
        baz = 'qux',
    })

    -- test that return true even if no cookie header
    r = new_request(new_http_request())
    r:parse_cookies()
    assert.equal(r.cookies, {})
end

function testcase.verify_csrf_cookie()
    -- test that verify X-CSRF-Token cookie
    local r = new_request(new_http_request())
    local name = 'X-CSRF-Token'
    assert(r.header:set('Cookie', name .. '=' .. generate_token(name)))
    assert.is_true(r:verify_csrf_cookie())

    -- test that verify X-CSRF-Token cookie
    r = new_request(new_http_request())
    assert(r.header:set('Cookie', name .. '=invalid_' .. generate_token(name)))
    assert.is_false(r:verify_csrf_cookie())
end


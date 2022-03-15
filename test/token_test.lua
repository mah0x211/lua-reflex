require('luacov')
local testcase = require('testcase')
local hmac = require('openssl').hmac.hmac
local token = require('reflex.token')

function testcase.token()
    -- test that generate a token
    local s = assert(token.generate('foobar'))
    -- confirm
    local sha1hex_len = 160 / 8 * 2
    local hash = string.sub(s, 1, sha1hex_len)
    local msg = string.sub(s, sha1hex_len + 2)
    assert.equal(hash, hmac('sha1', msg, 'foobar'))

    -- test that returns true
    assert.is_true(token.verify('foobar', s))

    -- test that returns true
    assert.is_false(token.verify('foobar', s .. 'hello'))

    -- test that throws error if invalid key
    local err = assert.throws(token.generate, {})
    assert.match(err, 'key must be string')

    -- test that throws error if invalid key
    err = assert.throws(token.verify, {})
    assert.match(err, 'key must be string')

    -- test that throws error if invalid token
    err = assert.throws(token.verify, 'hello', {})
    assert.match(err, 'token must be string')
end

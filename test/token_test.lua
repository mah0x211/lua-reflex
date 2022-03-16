require('luacov')
local testcase = require('testcase')
local hmacsha224 = require('hmac').sha224
local token = require('reflex.token')

local function hmacsha(msg, key)
    local ctx = hmacsha224(key)
    ctx:update(msg)
    return ctx:final()
end

function testcase.token()
    -- test that generate a token
    local s = assert(token.generate('foobar'))
    -- confirm
    local shahex_len = 224 / 8 * 2
    local hash = string.sub(s, 1, shahex_len)
    local msg = string.sub(s, shahex_len + 2)
    assert.equal(hash, hmacsha(msg, 'foobar'))

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

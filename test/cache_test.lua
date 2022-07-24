require('luacov')
local unpack = unpack or table.unpack
local testcase = require('testcase')
local sleep = require('testcase.timer').sleep
local cache = require('reflex.cache')

function testcase.new()
    -- test that returns a new cache object
    assert(cache.new())
end

function testcase.set()
    local c = assert(cache.new())

    -- test that set a value associated with key
    assert(c:set('foo', 'bar'))

    -- test that set a value associated with key and ttl
    assert(c:set('hello', 'world', 10))

    -- test that return false and error
    for _, v in ipairs({
        {
            args = {
                'foo bar',
            },
            exp = 'key must be string',
        },
        {
            args = {
                'foo',
                'bar',
                true,
            },
            exp = 'ttl must be integer',
        },
    }) do
        local ok, err = c:set(unpack(v.args))
        assert.is_false(ok)
        assert.match(err, v.exp, false)
    end
end

function testcase.get()
    local c = assert(cache.new())

    -- test that return a value associated with key
    assert(c:set('foo', 'bar', 3))
    local val = assert(c:get('foo'))
    assert.equal(val, 'bar')

    -- test that return a value associated with key and extends the lifetime
    assert(c:get('foo', true))

    -- test that return nil after reached to ttl
    sleep(1)
    assert(c:get('foo'))
    sleep(2)
    assert.is_nil(c:get('foo'))

    -- test that return nil and error
    for _, v in ipairs({
        {
            args = {
                'foo bar',
            },
            exp = 'key must be string',
        },
        {
            args = {
                'foo',
                'bar',
            },
            exp = 'touch must be boolean',
        },
    }) do
        local res, err = c:get(unpack(v.args))
        assert.is_nil(res)
        assert.match(err, v.exp, false)
    end
end

function testcase.del()
    local c = assert(cache.new())

    -- test that return true if a value associated with key has been deleted
    assert(c:set('foo', 'bar'))
    assert.equal(c:get('foo'), 'bar')
    assert.is_true(c:del('foo'))
    assert.is_nil(c:get('foo'))

    -- test that return false if a value associated with key not found
    assert.is_false(c:del('foo'))

    -- test that return false and error
    local ok, err = c:del({})
    assert.is_false(ok)
    assert.match(err, 'key must be string')
end

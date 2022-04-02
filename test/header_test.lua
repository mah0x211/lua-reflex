require('luacov')
local testcase = require('testcase')
local header = require('reflex.header')

function testcase.new()
    -- test that return new Header
    assert(header.new())
end

function testcase.set()
    local h = header.new()

    -- test that set key-value pair
    assert(h:set('foo', 'bar'))
    -- confirm
    assert.equal(h:get('foo'), {
        'bar',
    })

    -- test that set table value
    assert(h:set('foo', {
        'bar',
        'baz',
    }))
    -- confirm
    assert.equal(h:get('foo'), {
        'bar',
        'baz',
    })

    -- test that replace with new value
    assert(h:set('foo', 'baa'))
    -- confirm
    assert.equal(h:get('foo'), {
        'baa',
    })

    -- test that delete key
    assert(h:set('foo'))
    -- confirm
    assert.is_nil(h:get('foo'))

    -- test that empty-value treat as nil
    assert(h:set('foo', 'bar'))
    assert(h:set('foo', {}))

    -- test that return false if key is not exists
    assert.is_false(h:set('foo'))

    -- test that throws an error if key is not valid header key
    local err = assert.throws(h.set, h, 1)
    assert.match(err, 'key must be string matching')
    err = assert.throws(h.set, h, 'foo bar')
    assert.match(err, 'key must be string matching')

    -- test that throws an error if val is not string or string[]
    err = assert.throws(h.set, h, 'foo', 1)
    assert.match(err, 'val must be string or string[]')
    err = assert.throws(h.set, h, 'foo', {
        'foo',
        1,
    })
    assert.match(err, 'val#2 must be string')
end

function testcase.add()
    local h = header.new()

    -- test that add key-value pair
    assert(h:add('foo', 'bar'))
    -- confirm
    assert.equal(h:get('foo'), {
        'bar',
    })

    -- test that add table value
    assert(h:add('foo', {
        'baz',
        'qux',
    }))
    -- confirm
    assert.equal(h:get('foo'), {
        'bar',
        'baz',
        'qux',
    })

    -- test that throws an error if key is not valid header key
    local err = assert.throws(h.add, h, 1)
    assert.match(err, 'key must be string matching')
    err = assert.throws(h.add, h, 'foo bar')
    assert.match(err, 'key must be string matching')

    -- test that throws an error if val is not string or string[]
    err = assert.throws(h.add, h, 'foo', 1)
    assert.match(err, 'val must be string or string[]')
    err = assert.throws(h.add, h, 'foo', {
        'foo',
        1,
    })
    assert.match(err, 'val#2 must be string')
end

function testcase.get()
    local h = header.new()
    assert(h:set('foo-bar', 'baz-qux'))

    -- test that return nil
    assert.is_nil(h:get('foo', 'bar'))

    -- test that get return value and capitalized key
    local v, k = h:get('foo-bar')
    assert.equal({
        k = k,
        v = v,
    }, {
        k = 'Foo-Bar',
        v = {
            'baz-qux',
        },
    })

    -- test that key is case-insensitive
    v, k = h:get('fOo-BaR')
    assert.equal({
        k = k,
        v = v,
    }, {
        k = 'Foo-Bar',
        v = {
            'baz-qux',
        },
    })

    -- test that throws an error if key is not valid header key
    local err = assert.throws(h.get, h, 1)
    assert.match(err, 'key must be string')
end


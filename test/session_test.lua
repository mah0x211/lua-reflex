require('luacov')
local testcase = require('testcase')
local cache = require('reflex.cache')
local session = require('reflex.session')
local yyjson = require('yyjson')
local parse_baked_cookie = require('cookie').parse_baked_cookie

local CACHE

function testcase.before_each()
    -- restore default value
    CACHE = cache.new()
    session.set_store(CACHE)
    session.set_name('sid')
    session.set_maxage(60 * 30)
end

function testcase.set_store()
    -- test that custom store can be used as the session storage
    local noop = function()
    end
    local store = {
        set = noop,
        get = noop,
        del = noop,
    }
    assert(pcall(session.set_store, store))

    -- test that throws an error if store is invalid
    local err = assert.throws(session.set_store, {})
    assert.match(err, 'store must have .+ methods', false)
end

function testcase.set_name()
    -- test that throws an error
    local err = assert.throws(session.set_name, 'foo-bar')
    assert.match(err, 'name must be string of')
end

function testcase.set_maxage()
    -- test that throws an error
    for _, v in ipairs({
        {},
        true,
        -1,
        1 / 0,
        0 / 0,
    }) do
        local err = assert.throws(session.set_maxage, v)
        assert.match(err, 'maxage must be integer greater than 0')
    end
end

function testcase.new()
    -- test that create a new session
    assert(session.new())
end

function testcase.set()
    local s = assert(session.new())

    -- test that set a value to session
    assert(pcall(s.set, s, 'foo', 'bar'))

    -- test that throws an error if key is invalid
    local err = assert.throws(s.set, s, ' \n')
    assert.match(err, 'key must be non-empty string')
end

function testcase.del()
    local s = assert(session.new())

    -- test that get a value associated with key
    s:set('foo', 'bar')
    assert.equal(s:get('foo'), 'bar')

    -- test that throws an error if key is invalid
    local err = assert.throws(s.get, s, {})
    assert.match(err, 'key must be string')
end

local TEST_STORE = {
    set = function()
        return false, 'test-set-error'
    end,
    get = function()
        return nil, 'test-get-error'
    end,
    del = function()
        return nil, 'test-del-error'
    end,
}

function testcase.save()
    local s = assert(session.new())

    -- test that save session value
    session.set_name('session')
    session.set_maxage(60 * 60)
    s:set('foo', {
        bar = {
            baz = {
                qux = {
                    'quux',
                },
            },
            baa = function()
            end,
        },
    })
    local ok, err, cookie = s:save({
        path = '/pathname',
    })
    assert(ok, err)
    local c = assert(parse_baked_cookie(cookie))
    -- confirm cookie
    c.expires = nil
    assert.equal(c, {
        httponly = true,
        maxage = 60 * 60,
        name = 'session',
        samesite = 'lax',
        secure = true,
        path = '/pathname',
        value = s.id,
    })
    -- confirm store
    local json = assert(CACHE:get(s.id))
    local data = assert(yyjson.decode(json))
    assert.equal(data, {
        [-1] = yyjson.AS_OBJECT,
        foo = {
            [-1] = yyjson.AS_OBJECT,
            bar = {
                [-1] = yyjson.AS_OBJECT,
                baz = {
                    [-1] = yyjson.AS_OBJECT,
                    qux = {
                        [-1] = yyjson.AS_ARRAY,
                        'quux',
                    },
                },
            },
        },
    })

    -- test that return an error from store
    session.set_store(TEST_STORE)
    ok, err, cookie = s:save()
    assert.is_false(ok)
    assert.equal(err, 'test-set-error')
    assert.is_nil(cookie)

    -- test that throws an error
    err = assert.throws(s.save, s, 1)
    assert.match(err, 'attr must be table')
end

function testcase.restore()
    local s = assert(session.new())
    s:set('foo', {
        bar = {
            baz = 'qux',
        },
    })
    local _, _, cookie = assert(s:save())
    local c = parse_baked_cookie(cookie)
    local sid = c.value

    -- test that restore session
    s = assert(session.new())
    assert.not_equal(s.id, sid)
    assert(s:restore(sid))
    assert.equal(s.id, sid)
    assert.equal(s:get('foo'), {
        [-1] = yyjson.AS_OBJECT,
        bar = {
            [-1] = yyjson.AS_OBJECT,
            baz = 'qux',
        },
    })

    -- test that cannot restore with unknown(or expired) session-id
    local ok, err = s:restore('foo')
    assert.is_false(ok)
    assert.is_nil(err)

    -- test that return an error from store
    session.set_store(TEST_STORE)
    ok, err = s:restore('foo')
    assert.is_false(ok)
    assert.equal(err, 'test-get-error')

    -- test that throws an error
    err = assert.throws(s.restore, s, true)
    assert.match(err, 'id must be string')
end

function testcase.destroy()
    local s = assert(session.new())
    s:set('foo', {
        bar = {
            baz = 'qux',
        },
    })
    local ok, err, cookie = s:save()
    assert(ok, err)
    local c = parse_baked_cookie(cookie)
    local sid = c.value
    s = assert(session.new())
    assert.not_equal(s.id, sid)
    assert(s:restore(sid))
    assert.equal(s.id, sid)

    -- test that destroy a session
    ok, err, cookie = s:destroy({
        domain = 'example.com',
    })
    assert(ok, err)
    -- confirm cookie
    c = parse_baked_cookie(cookie)
    c.expires = nil
    assert.equal(c, {
        domain = 'example.com',
        httponly = true,
        maxage = -60,
        name = 'sid',
        samesite = 'lax',
        secure = true,
        value = 'void',
    })
    -- confirm store
    assert.is_nil(CACHE:get(sid))

    -- test that return an error from store
    session.set_store(TEST_STORE)
    ok, err = s:destroy()
    assert.is_false(ok)
    assert.equal(err, 'test-del-error')

    -- test that throws an error
    err = assert.throws(s.destroy, s, true)
    assert.match(err, 'attr must be table')
end


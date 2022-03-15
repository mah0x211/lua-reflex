require('luacov')
local testcase = require('testcase')
local cache = require('reflex.cache')
local session = require('reflex.session')
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

function testcase.get_set_name()
    -- test that returns a current name
    assert.equal(session.get_name(), 'sid')

    -- test that set a name
    session.set_name('foo')
    assert.equal(session.get_name(), 'foo')

    -- test that throws an error
    local err = assert.throws(session.set_name, 'foo-bar')
    assert.match(err, 'name must be string of')
end

function testcase.get_set_maxage()
    -- test that returns a current maxage
    assert.equal(session.get_maxage(), 60 * 30)

    -- test that returns a current maxage
    session.set_maxage(30)
    assert.equal(session.get_maxage(), 30)

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
    local data = assert(CACHE:get(s.id))
    assert.equal(data, {
        foo = {
            bar = {
                baz = {
                    qux = {
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
        bar = {
            baz = 'qux',
        },
    })

    -- test that restore session by new function
    s = assert(session.new(sid))
    assert.equal(s.id, sid)
    assert.equal(s:get('foo'), {
        bar = {
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

    local _, nerr = session.new('foo')
    assert.is_nil(_)
    assert.equal(nerr, 'test-get-error')

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
        path = '/',
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


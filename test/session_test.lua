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
    session.reset_default()
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

function testcase.set_default()
    -- test that returns a current default name and attr
    local name, attr = session.get_default()
    assert.equal(name, 'sid')
    assert.is_table(attr)

    -- test that set default name
    session.set_default('foo')
    local newname, newattr = session.get_default()
    assert.equal(newname, 'foo')
    assert.equal(newattr, attr)

    -- test that set default attributes
    name = newname
    session.set_default(nil, {
        domain = 'example.com',
        maxage = 30,
        secure = false,
        httponly = false,
        path = 'hello/world',
    })
    newname, newattr = session.get_default()
    assert.equal(newname, name)
    assert.equal(newattr, {
        domain = 'example.com',
        maxage = 30,
        secure = false,
        httponly = false,
        path = 'hello/world',
        samesite = 'lax',
    })

    -- test that remove domain attribute
    session.set_default(nil, {})
    newname, newattr = session.get_default()
    assert.equal(newname, name)
    assert.equal(newattr, {
        maxage = 30,
        secure = false,
        httponly = false,
        path = 'hello/world',
        samesite = 'lax',
    })

    -- test that throws an error if maxage is not greater than 0
    local err = assert.throws(session.set_default, nil, {
        maxage = 0,
    })
    assert.match(err, 'maxage must be integer greater than 0')

    -- test that thows an error if attribute value is invalid
    err = assert.throws(session.set_default, nil, {
        secure = {},
    })
    assert.match(err, 'secure must be boolean')
end

function testcase.set_get_name()
    -- test that get a current default name
    assert.equal(session.get_name(), 'sid')

    -- test that set name
    session.set_name('foo')
    assert.equal(session.get_name(), 'foo')

    -- test that revert to default name
    session.set_name()
    assert.equal(session.get_name(), 'sid')

    -- test that throws an error if argument is invalid
    local err = assert.throws(session.set_name, {})
    assert.match(err, 'name must be valid cookie-name string')
end

function testcase.new()
    -- test that create a new session
    assert(session.new())
end

function testcase.set_get_delete()
    local s = assert(session.new())

    -- test that set a value to session
    s:set('foo', 'bar')
    s:set('qux', 'quux')
    assert.equal(s:get('foo'), 'bar')
    assert.equal(s:get('qux'), 'quux')

    -- test that set a nil to delete key
    s:set('foo')
    assert.is_nil(s:get('foo'))

    -- test that return a deleted value
    assert.equal(s:delete('qux'), 'quux')
    assert.is_nil(s:get('qux'))

    -- test that throws an error if key is invalid
    local err = assert.throws(s.set, s, ' \n')
    assert.match(err, 'key must be non-empty string')

    -- test that throws an error if key is not string
    err = assert.throws(s.get, s, {})
    assert.match(err, 'key must be string')

    -- test that throws an error if key is not string
    err = assert.throws(s.delete, s, 1)
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
    session.set_default('session', {
        maxage = 60 * 60,
    })
    s:set('foo', {
        bar = {
            baz = {
                qux = {
                    'quux',
                },
            },
        },
    })
    local cookie, err = assert(s:save({
        path = '/pathname',
    }))
    assert.is_nil(err)
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
    cookie, err = s:save()
    assert.is_nil(cookie)
    assert.equal(err, 'test-set-error')

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
    local cookie = assert(s:save())
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
    local cookie, err = assert(s:save())
    assert.is_nil(err)
    local c = parse_baked_cookie(cookie)
    local sid = c.value
    s = assert(session.new())
    assert.not_equal(s.id, sid)
    assert(s:restore(sid))
    assert.equal(s.id, sid)

    -- test that destroy a session
    cookie, err = assert(s:destroy({
        domain = 'example.com',
    }))
    assert.is_nil(err)
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
    cookie, err = s:destroy()
    assert.is_nil(cookie)
    assert.equal(err, 'test-del-error')

    -- test that throws an error
    err = assert.throws(s.destroy, s, true)
    assert.match(err, 'attr must be table')
end


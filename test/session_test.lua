require('luacov')
local testcase = require('testcase')
local assert = require('assert')
local cache = require('cache.inmem')
local session = require('reflex.session')
local parse_baked_cookie = require('cookie').parse_baked_cookie

local CACHE

function testcase.before_each()
    -- restore default value
    CACHE = cache.new(10)
    session.set_store(CACHE)
    session.set_cookie_config()
end

function testcase.set_store()
    -- test that custom store can be used as the session storage
    local noop = function()
    end
    local store = {
        set = noop,
        get = noop,
        delete = noop,
        rename = noop,
        keys = noop,
        evict = noop,
    }
    assert(pcall(session.set_store, store))

    -- test that throws an error if store is invalid
    local err = assert.throws(session.set_store, {})
    assert.re_match(err, 'store must be implemented .+ method')
end

function testcase.set_get_cookie_config()
    -- test that return a current default attributes
    assert.equal(session.get_cookie_config(), {
        name = 'sid',
        path = '/',
        maxage = 60 * 30,
        secure = true,
        httponly = true,
        samesite = 'lax',
    })

    -- test that set default attributes
    session.set_cookie_config({
        domain = 'example.com',
        maxage = 30,
        secure = false,
        httponly = false,
        path = 'hello/world',
    })
    assert.equal(session.get_cookie_config(), {
        name = 'sid',
        domain = 'example.com',
        maxage = 30,
        secure = false,
        httponly = false,
        path = 'hello/world',
        samesite = 'lax',
    })

    -- test that revert to module default attribute
    session.set_cookie_config()
    assert.equal(session.get_cookie_config(), {
        name = 'sid',
        path = '/',
        maxage = 60 * 30,
        secure = true,
        httponly = true,
        samesite = 'lax',
    })
end

function testcase.new()
    -- test that create a new session
    local s = assert(session.new())
    assert.re_match(s, '^session\\.Session: ')
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
    s = assert(session.restore(sid))
    assert.equal(s.id, sid)
    assert.equal(s:get('foo'), {
        bar = {
            baz = 'qux',
        },
    })

    -- test that cannot restore with unknown(or expired) session-id
    local err
    s, err = session.restore('foo')
    assert.is_nil(err)
    assert.is_nil(s)

    -- test that throws an error if argument is invalid
    err = assert.throws(session.restore, true)
    assert.match(err, 'sid must be string')
end


require('luacov')
local testcase = require('testcase')
local new_router = require('reflex.router')
local status = require('reflex.status')

function testcase.new()
    -- test that create new router
    local _, routes = assert(new_router('./testdir/html'))
    local compare = {
        any = {
            ['/:user/posts/*id'] = {
                handlers = {
                    {
                        method = 'all',
                        name = '/#1.block_ip.lua',
                    },
                    {
                        method = 'all',
                        name = '/#2.check_user.lua',
                    },
                    {
                        method = 'all',
                        name = '/$user/#1.block_user.lua',
                    },
                    {
                        method = 'all',
                        name = '/$user/posts/#1.extract_id.lua',
                    },
                    {
                        method = 'any',
                        name = '/$user/posts/@*id.lua',
                    },
                },
            },
        },
        get = {
            ['/'] = {
                handlers = {
                    {
                        method = 'all',
                        name = '/#1.block_ip.lua',
                    },
                    {
                        method = 'all',
                        name = '/#2.check_user.lua',
                    },
                    {
                        method = 'get',
                        name = '/@index.lua',
                    },
                },
            },
            ['/favicon.ico'] = {
                handlers = {
                    {
                        method = 'all',
                        name = '/#1.block_ip.lua',
                    },
                    {
                        method = 'all',
                        name = '/#2.check_user.lua',
                    },
                },
            },
            ['/img/example.jpg'] = {
                handlers = {
                    {
                        method = 'all',
                        name = '/#1.block_ip.lua',
                    },
                    {
                        method = 'all',
                        name = '/#2.check_user.lua',
                    },
                },
            },
            ['/api'] = {
                handlers = {
                    {
                        method = 'all',
                        name = '/#1.block_ip.lua',
                    },
                    {
                        method = 'all',
                        name = '/#2.check_user.lua',
                    },
                    {
                        method = 'get',
                        name = '/api/@index.lua',
                    },
                },
            },
            ['/signin'] = {
                handlers = {
                    {
                        method = 'get',
                        name = '/signin/@index.lua',
                    },
                },
            },
            ['/signout'] = {
                handlers = {},
            },
            ['/:user'] = {
                handlers = {
                    {
                        method = 'all',
                        name = '/#1.block_ip.lua',
                    },
                    {
                        method = 'all',
                        name = '/#2.check_user.lua',
                    },
                    {
                        method = 'all',
                        name = '/$user/#1.block_user.lua',
                    },
                    {
                        method = 'get',
                        name = '/$user/@index.lua',
                    },
                },
            },
            ['/:user/posts'] = {
                handlers = {
                    {
                        method = 'all',
                        name = '/#1.block_ip.lua',
                    },
                    {
                        method = 'all',
                        name = '/#2.check_user.lua',
                    },
                    {
                        method = 'all',
                        name = '/$user/#1.block_user.lua',
                    },
                    {
                        method = 'all',
                        name = '/$user/posts/#1.extract_id.lua',
                    },
                    {
                        method = 'get',
                        name = '/$user/posts/@index.lua',
                    },
                },
            },
            ['/:user/posts/*id'] = {
                handlers = {
                    {
                        method = 'all',
                        name = '/#1.block_ip.lua',
                    },
                    {
                        method = 'all',
                        name = '/#2.check_user.lua',
                    },
                    {
                        method = 'all',
                        name = '/$user/#1.block_user.lua',
                    },
                    {
                        method = 'all',
                        name = '/$user/posts/#1.extract_id.lua',
                    },
                    {
                        method = 'get',
                        name = '/$user/posts/@*id.lua',
                    },
                },
            },
        },
        post = {
            ['/signin'] = {
                handlers = {
                    {
                        method = 'post',
                        name = '/signin/@index.lua',
                    },
                },
            },
            ['/api'] = {
                handlers = {
                    {
                        method = 'all',
                        name = '/#1.block_ip.lua',
                    },
                    {
                        method = 'all',
                        name = '/#2.check_user.lua',
                    },
                    {
                        method = 'post',
                        name = '/api/@index.lua',
                    },
                },
            },
        },
    }
    for _, route in ipairs(routes) do
        for k, v in pairs(compare[route.method][route.rpath]) do
            assert.equal(route[k], v)
        end
    end

    -- test that throw an error if rootdir is invalid
    local err = assert.throws(new_router, {})
    assert.match(err, 'rootdir must be string')

    -- test that throw an error if opts is invalid
    err = assert.throws(new_router, 'html', 'hello')
    assert.match(err, 'opts must be table')

    -- test that throw an error if rootdir is not exists
    err = assert.throws(new_router, 'unknown_rootdir')
    assert.match(err, 'unknown_rootdir.+ directory', false)
end

function testcase.serve()
    local r = assert(new_router('./testdir/html'))

    -- test that serve request
    for method, v in pairs({
        any = {
            ['/foobar/posts/1234'] = {
                block_ip = 'all',
                check_user = 'all',
                block_user = 'all',
                extract_id = 'all',
                glob = {
                    user = 'foobar',
                    id = '1234',
                },
                user_posts_id = 'any',
            },
        },
        get = {
            ['/'] = {
                block_ip = 'all',
                check_user = 'all',
                glob = {},
                ['/'] = 'get',
            },
            ['/signin'] = {
                glob = {},
                signin = 'get',
            },
            ['/foobar'] = {
                block_ip = 'all',
                check_user = 'all',
                block_user = 'all',
                glob = {
                    user = 'foobar',
                },
                user = 'get',
            },
            ['/foobar/posts'] = {
                block_ip = 'all',
                check_user = 'all',
                block_user = 'all',
                extract_id = 'all',
                glob = {
                    user = 'foobar',
                },
                user_posts = 'get',
            },
            ['/foobar/posts/9876'] = {
                block_ip = 'all',
                check_user = 'all',
                block_user = 'all',
                extract_id = 'all',
                glob = {
                    user = 'foobar',
                    id = '9876',
                },
                user_posts_id = 'get',
            },
        },
        post = {
            ['/signin'] = {
                glob = {},
                signin = 'post',
            },
        },
    }) do
        for rpath, cmp in pairs(v) do
            local req = {}
            local data = {}
            local rc, err, file = r:serve(method, rpath, req, data)
            assert.equal(rc, status.OK)
            assert.is_nil(err)
            assert.is_table(file)
            assert.equal(data, cmp)
        end
    end

    -- test that returns METHOD_NOT_ALLOWED
    local rc, err = r:serve('put', '/api', {}, {})
    assert.equal(rc, status.METHOD_NOT_ALLOWED)
    assert.is_nil(err)

    -- test that returns NOT_FOUND
    rc, err = r:serve('get', '/api/unknown', {}, {})
    assert.equal(rc, status.NOT_FOUND)
    assert.is_nil(err)

    for _, pathname in ipairs({
        '/api/unknown',
        '/foobar/*',
        '/foobar/^',
        '/foobar/#',
    }) do
        rc, err = r:serve('get', pathname, {}, {})
        assert.equal(rc, status.NOT_FOUND)
        assert.is_nil(err)
    end

    -- test that returns INTERNAL_SERVER_ERROR
    rc, err = r:serve('get', '/api', {}, {})
    assert.equal(rc, status.INTERNAL_SERVER_ERROR)
    assert.match(err, 'attempt to concatenate')

    -- test that returns INTERNAL_SERVER_ERROR
    rc, err = r:serve('post', '/api', {}, {})
    assert.equal(rc, status.INTERNAL_SERVER_ERROR)
    assert.match(err, 'invalid status code')

    -- test that throw an error if method is invalid
    err = assert.throws(r.serve, r, {})
    assert.match(err, 'method must be string')

    -- test that throw an error if pathname is invalid
    err = assert.throws(r.serve, r, 'get', {})
    assert.match(err, 'pathname must be string')

    -- test that throw an error if req is invalid
    err = assert.throws(r.serve, r, 'get', '/', 'foo')
    assert.match(err, 'req must be table')

    -- test that throw an error if data is invalid
    err = assert.throws(r.serve, r, 'get', '/', {}, 'bar')
    assert.match(err, 'data must be table')
end

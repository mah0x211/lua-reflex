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
                header = {},
                body = {
                    block_ip = 'all',
                    check_user = 'all',
                    block_user = 'all',
                    extract_id = 'all',
                    params = {
                        user = 'foobar',
                        id = '1234',
                    },
                    user_posts_id = 'any',
                },
            },
        },
        get = {
            ['/'] = {
                header = {},
                body = {
                    block_ip = 'all',
                    check_user = 'all',
                    params = {},
                    ['/'] = 'get',
                },
            },
            ['/signin'] = {
                header = {},
                body = {
                    params = {},
                    signin = 'get',
                },
            },
            ['/foobar'] = {
                header = {},
                body = {
                    block_ip = 'all',
                    check_user = 'all',
                    block_user = 'all',
                    params = {
                        user = 'foobar',
                    },
                    user = 'get',
                },
            },
            ['/foobar/posts'] = {
                header = {},
                body = {
                    block_ip = 'all',
                    check_user = 'all',
                    block_user = 'all',
                    extract_id = 'all',
                    params = {
                        user = 'foobar',
                    },
                    user_posts = 'get',
                },
            },
            ['/foobar/posts/9876'] = {
                header = {},
                body = {
                    block_ip = 'all',
                    check_user = 'all',
                    block_user = 'all',
                    extract_id = 'all',
                    params = {
                        user = 'foobar',
                        id = '9876',
                    },
                    user_posts_id = 'get',
                },
            },
        },
        post = {
            ['/signin'] = {
                header = {},
                body = {
                    params = {},
                    signin = 'post',
                },
            },
        },
    }) do
        for rpath, cmp in pairs(v) do
            local req = {}
            local rsp = {
                header = {},
                body = {},
            }
            local rc, err, file = r:serve(method, rpath, req, rsp)
            assert.equal(rc, status.OK)
            assert.is_nil(err)
            assert.is_table(file)
            assert.equal(rsp, cmp)
        end
    end

    -- test that returns OK and file
    local rc, err, file = r:serve('get', '/signout', {}, {
        header = {},
        body = {},
    })
    assert.equal(rc, status.OK)
    assert.is_nil(err)
    assert.is_table(file)

    -- test that returns METHOD_NOT_ALLOWED if method is not a GET method
    rc, err, file = r:serve('post', '/signout', {}, {
        header = {},
        body = {},
    })
    assert.equal(rc, status.METHOD_NOT_ALLOWED)
    assert.is_nil(err)
    assert.is_nil(file)

    -- test that returns METHOD_NOT_ALLOWED
    rc, err = r:serve('put', '/api', {}, {
        header = {},
        body = {},
    })
    assert.equal(rc, status.METHOD_NOT_ALLOWED)
    assert.is_nil(err)

    -- test that returns NOT_FOUND
    rc, err = r:serve('get', '/api/unknown', {}, {
        header = {},
        body = {},
    })
    assert.equal(rc, status.NOT_FOUND)
    assert.is_nil(err)

    for _, pathname in ipairs({
        '/api/unknown',
        '/foobar/*',
        '/foobar/^',
        '/foobar/#',
    }) do
        rc, err = r:serve('get', pathname, {}, {
            header = {},
            body = {},
        })
        assert.equal(rc, status.NOT_FOUND)
        assert.is_nil(err)
    end

    -- test that returns INTERNAL_SERVER_ERROR if router returns an error
    local router = r.router
    r.router = {
        lookup = function()
            return nil, 'router error'
        end,
    }
    rc, err = r:serve('get', '/api', {}, {
        header = {},
        body = {},
    })
    r.router = router
    assert.equal(rc, status.INTERNAL_SERVER_ERROR)
    assert.match(err, 'router error')

    -- test that returns INTERNAL_SERVER_ERROR if invalid hander
    rc, err = r:serve('get', '/api', {}, {
        header = {},
        body = {},
    })
    assert.equal(rc, status.INTERNAL_SERVER_ERROR)
    assert.match(err, 'attempt to concatenate')

    -- test that returns INTERNAL_SERVER_ERROR if handler returns a invalid status
    rc, err = r:serve('post', '/api', {}, {
        header = {},
        body = {},
    })
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
    assert.match(err, 'rsp must be table')

    -- test that throw an error if header is invalid
    err = assert.throws(r.serve, r, 'get', '/', {}, {})
    assert.match(err, 'rsp.header must be table')

    -- test that throw an error if header is invalid
    err = assert.throws(r.serve, r, 'get', '/', {}, {
        header = {},
    })
    assert.match(err, 'rsp.body must be table')
end

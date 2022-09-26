require('luacov')
local testcase = require('testcase')
local new_reponse = require('reflex.response')
local new_router = require('reflex.router')
local status = require('reflex.status')

local function new_request(method, uri)
    return {
        method = method,
        path = uri,
        header = {},
    }
end

function testcase.new()
    -- test that create new router
    local _, routes = assert(new_router('./testdir/html'))
    local compare = {
        all = {
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
                },
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
                },
            },

        },
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

function testcase.lookup()
    local r = assert(new_router('./testdir/html'))

    -- test that serve request
    for pathname, v in pairs({
        ['/'] = {
            route = {
                file = {
                    rpath = '/index.html',
                },
                methods = {
                    get = {
                        [1] = {
                            method = "all",
                            name = "/#1.block_ip.lua",
                            type = "filter",
                        },
                        [2] = {
                            method = "all",
                            name = "/#2.check_user.lua",
                            type = "filter",
                        },
                        [3] = {
                            method = "get",
                            name = "/@index.lua",
                            type = "handler",
                        },
                    },
                },
            },
            glob = {},
        },
        ['/signin'] = {
            route = {
                file = {
                    rpath = '/signin/index.html',
                },
                methods = {
                    get = {
                        [1] = {
                            method = "get",
                            name = "/signin/@index.lua",
                            type = "handler",
                        },
                    },
                    post = {
                        [1] = {
                            method = "post",
                            name = "/signin/@index.lua",
                            type = "handler",
                        },
                    },
                },
            },
            glob = {},
        },
        ['/foobar/posts/1234'] = {
            route = {
                file = {
                    rpath = '/$user/posts/*id.html',
                },
                methods = {
                    get = {
                        {
                            method = 'all',
                            name = "/#1.block_ip.lua",
                            type = "filter",
                        },
                        [2] = {
                            method = "all",
                            name = "/#2.check_user.lua",
                            type = "filter",
                        },
                        [3] = {
                            method = "all",
                            name = "/$user/#1.block_user.lua",
                            type = "filter",
                        },
                        [4] = {
                            method = "all",
                            name = "/$user/posts/#1.extract_id.lua",
                            type = "filter",
                        },
                        [5] = {
                            method = "get",
                            name = "/$user/posts/@*id.lua",
                            type = "handler",
                        },

                    },
                },
            },
            glob = {
                user = 'foobar',
                id = '1234',
            },
        },
    }) do
        local route, _, glob = r:lookup(pathname)
        assert.contains(route, v.route)
        assert.equal(glob, v.glob)
    end

    -- test that throw an error if res.body is invalid
    local err = assert.throws(r.lookup, r, {})
    assert.match(err, 'pathname must be string')
end

function testcase.serve()
    local r = assert(new_router('./testdir/html'))

    -- test that serve request
    for method, v in pairs({
        any = {
            ['/foobar/posts/1234'] = {
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
                body = {
                    block_ip = 'all',
                    check_user = 'all',
                    params = {},
                    ['/'] = 'get',
                },
            },
            ['/signin'] = {
                body = {
                    params = {},
                    signin = 'get',
                },
            },
            ['/foobar'] = {
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
                body = {
                    params = {},
                    signin = 'post',
                },
            },
        },
    }) do
        for rpath, cmp in pairs(v) do
            local rsp = new_reponse()
            local rc, err, file = r:serve(rsp, new_request(method, rpath))
            assert.equal(rc, status.OK)
            assert.is_nil(err)
            assert.is_table(file)
            assert.contains(rsp, cmp)
        end
    end

    -- test that returns OK and file
    local rc, err, file = r:serve(new_reponse(), new_request('get', '/signout'))
    assert.equal(rc, status.OK)
    assert.is_nil(err)
    assert.is_table(file)

    -- test that returns METHOD_NOT_ALLOWED if method is not a GET method
    rc, err, file = r:serve(new_reponse(), new_request('post', '/signout'))
    assert.equal(rc, status.METHOD_NOT_ALLOWED)
    assert.is_nil(err)
    assert.is_nil(file)

    -- test that returns METHOD_NOT_ALLOWED
    rc, err, file = r:serve(new_reponse(), new_request('put', '/signin'))
    assert.equal(rc, status.METHOD_NOT_ALLOWED)
    assert.is_nil(err)
    assert.is_nil(file)

    -- test that returns NOT_FOUND
    rc, err, file = r:serve(new_reponse(), new_request('get', '/api/unknown'))
    assert.equal(rc, status.NOT_FOUND)
    assert.is_nil(err)
    assert.is_nil(file)

    for _, pathname in ipairs({
        '/api/unknown',
        '/foobar/*',
        '/foobar/^',
        '/foobar/#',
    }) do
        rc, err, file = r:serve(new_reponse(), new_request('get', pathname))
        assert.equal(rc, status.NOT_FOUND)
        assert.is_nil(err)
        assert.is_nil(file)
    end

    -- test that returns INTERNAL_SERVER_ERROR if router returns an error
    local router = r.router
    r.router = {
        lookup = function()
            return nil, 'router error'
        end,
    }
    local res = new_reponse()
    rc, err, file = r:serve(res, new_request('get', '/api'))
    r.router = router
    assert.equal(rc, status.INTERNAL_SERVER_ERROR)
    assert.is_nil(err)
    assert.is_nil(file)
    assert.match(res.body.error.message, 'router error')

    -- test that returns INTERNAL_SERVER_ERROR if invalid hander
    res = new_reponse()
    rc, err, file = r:serve(res, new_request('get', '/api'))
    assert.is_nil(rc)
    assert.match(err, 'testdir/html/api/@index.lua:2')
    assert.is_nil(file)

    -- test that returns INTERNAL_SERVER_ERROR if handler returns a invalid status
    res = new_reponse()
    rc, err, file = r:serve(res, new_request('post', '/api'))
    assert.is_nil(rc)
    assert.match(err, '/api/@index.lua returns an invalid status code')
    assert.is_nil(file)

    -- test that throw an error if res is invalid
    err = assert.throws(r.serve, r, 'bar')
    assert.match(err, 'res must be table')

    -- test that throw an error if res.header is invalid
    err = assert.throws(r.serve, r, {})
    assert.match(err, 'res.header must be table')

    -- test that throw an error if res.body is invalid
    err = assert.throws(r.serve, r, {
        header = {},
    })
    assert.match(err, 'res.body must be table')

    -- test that throw an error if req is invalid
    err = assert.throws(r.serve, r, res, 'foo')
    assert.match(err, 'req must be table')

    -- test that throw an error if method is invalid
    err = assert.throws(r.serve, r, res, new_request({}, '/'))
    assert.match(err, 'req.method must be string')

    -- test that throw an error if path is invalid
    err = assert.throws(r.serve, r, res, new_request('get', {}))
    assert.match(err, 'req.path must be string')

    -- test that throw an error if uri is invalid
    local req = new_request('get', '/')
    req.header = nil
    err = assert.throws(r.serve, r, res, req)
    assert.match(err, 'req.header must be table')
end

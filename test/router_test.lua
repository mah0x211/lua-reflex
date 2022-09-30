require('luacov')
local testcase = require('testcase')
local new_router = require('reflex.router')

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


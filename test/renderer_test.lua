require('luacov')
local testcase = require('testcase')
local new_renderer = require('reflex.renderer')

function testcase.new()
    -- test that create a new renderer
    assert(new_renderer('testdir/html', nil, nil, {}))

    -- test that throws an error if invalid rootdir argument
    local err = assert.throws(new_renderer, true)
    assert.match(err, 'rootdir must be string')

    err = assert.throws(new_renderer, 'unknown-dir')
    assert.match(err, 'failed to .+ directory', false)

    -- test that throws an error if invalid follow_symlink argument
    err = assert.throws(new_renderer, 'unknown-dir', {})
    assert.match(err, 'follow_symlink must be boolean')

    -- test that throws an error if invalid cache argument
    err = assert.throws(new_renderer, 'unknown-dir', nil, {})
    assert.match(err, 'cache must be boolean')

    -- test that throws an error if invalid env argument
    err = assert.throws(new_renderer, 'unknown-dir', nil, nil, 'foo')
    assert.match(err, 'env must be table')
end

function testcase.add()
    local r = new_renderer('testdir/html')

    -- test that add file
    assert(r:add('/index.html'))

    -- test that return false if pathname is not found
    local ok, err = r:add('/unknown_file.html')
    assert.is_false(ok)
    assert.is_nil(err)

    -- test that return an error if invalid template
    ok, err = r:add('/.layout/invalid.html')
    assert.is_false(ok)
    assert.match(err, 'invalid tag')

    -- test that throws an error if invalid pathname argument
    err = assert.throws(r.add, r, true)
    assert.match(err, 'pathname must be string')
end

function testcase.del()
    local r = new_renderer('testdir/html')
    assert(r:add('/index.html'))

    -- test that del file
    assert(r:del('/index.html'))

    -- test that return false if pathname is not found
    assert.is_false(r:del('/index.html'))

    -- test that throws an error if invalid pathname argument
    local err = assert.throws(r.del, r, true)
    assert.match(err, 'pathname must be string')
end

function testcase.exists()
    local r = new_renderer('testdir/html')
    assert(r:add('/index.html'))

    -- test that return true
    assert.is_true(r:exists('/index.html'))
    assert(r:del('/index.html'))

    -- test that return false
    assert.is_false(r:exists('/index.html'))

    -- test that throws an error if invalid pathname argument
    local err = assert.throws(r.exists, r, true)
    assert.match(err, 'pathname must be string')
end

function testcase.render()
    local r = new_renderer('testdir/html')
    assert(r:add('/index.html'))

    -- test that returns rendered templates
    local s = assert(r:render('/index.html', {
        hello = 'hello world',
    }))
    assert.equal(s, 'header\nhello world\nfooter\n')

    -- test that templates has been deleted after rendered
    assert.is_false(r:exists('/index.html'))

    -- test that returns an error
    local err
    s, err = r:render('/unknown.html', {
        hello = 'hello world',
    })
    assert.is_nil(s)
    assert.match(err, 'not found')

    -- test that throws an error if invalid pathname argument
    err = assert.throws(r.render, r, {})
    assert.match(err, 'pathname must be string')

    -- test that throws an error if invalid data argument
    err = assert.throws(r.render, r, '/foo/bar', true)
    assert.match(err, 'data must be table')

end

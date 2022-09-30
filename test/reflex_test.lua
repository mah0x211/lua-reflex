require('luacov')
local testcase = require('testcase')
local reflex = require('reflex')
local code2message = require('reflex.status').code2message

function testcase.is_template()
    local refx = reflex({
        document = {
            rootdir = 'testdir/html',
        },
        template = {
            files = {
                ['.html'] = true,
            },
        },
    })

    -- test that return a true if specified extension defined in template.files table
    assert.is_true(refx:is_template('.html'))

    -- test that return a false if specified extension not defined in template.files table
    assert.is_false(refx:is_template('.txt'))
end

function testcase.render_page()
    local refx = reflex({
        document = {
            rootdir = 'testdir/html',
        },
        template = {
            files = {
                ['.html'] = true,
            },
        },
    })

    -- test that return a true if specified extension defined in template.files table
    local str, err = refx:render_page('/index.html', {
        hello = 'hello world!',
    })
    assert.equal(str, 'header\nhello world!\nfooter\n')
    assert.is_nil(err)
end

function testcase.render_error_page()
    local refx = reflex({
        document = {
            rootdir = 'testdir/html',
            error_pages = {
                [500] = '/index.html',
            },
        },
        template = {
            files = {
                ['.html'] = true,
            },
        },
    })

    -- test that render error page
    local str = assert(refx:render_error_page(500, {
        hello = 'internal_server_error',
    }))
    assert.equal(str, 'header\ninternal_server_error\nfooter\n')

    -- test that return status message
    str = assert(refx:render_error_page(400, {
        hello = 'internal_server_error',
    }))
    assert.equal(str, code2message(400) .. '\n')
end

require('luacov')
local testcase = require('testcase')
local reflex = require('reflex')

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
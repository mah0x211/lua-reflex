require('luacov')
local testcase = require('testcase')
local which = require('reflex.which')

function testcase.which()
    -- test that return a pathname
    local pathname = assert(which('testcase'))
    assert.match(pathname, '/testcase$', false)

    -- test that return a nil
    pathname = which('unknown command')
    assert.is_nil(pathname)

    -- test that throws an error
    local err = assert.throws(which, {})
    assert.match(err, 'filename must be string')
end

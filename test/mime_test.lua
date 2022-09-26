require('luacov')
local testcase = require('testcase')
local mime = require('reflex.mime')

function testcase.get_mimetype()
    -- test that get mimetype
    local res = assert(mime.get('./mime_test.lua'))
    assert.equal(res, 'text/plain; charset=us-ascii')

    -- test that determine mimetype with second argument
    res = assert(mime.get('./mime_test.lua', 'index.html'))
    assert.equal(res, 'text/html; charset=us-ascii')
end


require('luacov')
local testcase = require('testcase')
local errorf = require('reflex.errorf')

function testcase.errorf()
    -- test that throw an error
    local err = assert.throws(errorf, 'hello')
    assert.equal(err, 'hello')

    -- test that change the error level witg the first argument
    err = assert.throws(function()
        errorf(1, 'hello')
    end)
    assert.match(err, 'errorf_test.lua.+ hello', false)
end


require('luacov')
local testcase = require('testcase')
local fatalf = require('reflex.fatalf')

function testcase.fatalf()
    -- test that throw an error
    local err = assert.throws(fatalf, 'hello')
    assert.equal(err, 'hello')

    -- test that change the error level witg the first argument
    err = assert.throws(function()
        fatalf(1, 'hello')
    end)
    assert.match(err, 'fatalf_test.lua.+ hello', false)
end


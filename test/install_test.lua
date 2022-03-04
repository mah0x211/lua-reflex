require('luacov')
local testcase = require('testcase')
local install = require('reflex.install')

function testcase.install()
    -- test that return true
    assert(install('./testdir/dependencies.txt') == true, 'failed to install')

    -- test that throws an error if invalid argument
    local err = assert.throws(install)
    assert.match(err, 'string expected, got nil')

    -- test that throws an error if file could not open
    err = assert.throws(install, './testdir/dependencies_not_exist.txt')
    assert.match(err, 'failed to open')
end

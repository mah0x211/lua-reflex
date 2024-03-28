require('luacov')
local concat = table.concat
local testcase = require('testcase')
local assert = require('assert')
local exec = require('reflex.exec')

function testcase.exec()
    -- test that return true
    local ok, res = exec('lua', {
        '-e',
        [[io.stdout:write('hello\n')]],
    })
    assert(ok, res)
    assert.match(res, 'hello')

    -- test that return error with invalid syntax
    ok, res = exec('lua', {
        '-e',
        [[print(']],
    })
    assert.is_false(ok)
    assert.match(res, 'unfinished string')

    -- test that return error with invalid code
    ok, res = exec('lua', {
        '-e',
        [[print(foo + 2)]],
    })
    assert.is_false(ok)
    assert.match(res, 'attempt to perform arithmetic')

    -- test that throws an error if invalid argument
    local err = assert.throws(exec, 'lua', {
        '-v',
    }, nil, 1)
    assert.match(err, 'stdout must be function')

    err = assert.throws(exec, 'lua', {
        '-v',
    }, nil, nil, 1)
    assert.match(err, 'stderr must be function')
end

function testcase.exec_with_stdio()
    local outlines = {}
    local errlines = {}

    -- test that return true
    local ok, res = exec('lua', {
        '-e',
        [[io.stdout:write('hello\n'); io.stderr:write('world\n')]],
    }, nil, function(...)
        outlines[#outlines + 1] = concat({
            ...,
        }, ' ')
    end, function(line)
        errlines[#errlines + 1] = line
    end)
    assert(ok, res)
    assert.is_nil(res)
    assert.equal(outlines, {
        [[lua -e io.stdout:write('hello\n'); io.stderr:write('world\n')]],
        'hello',
    })
    assert.equal(errlines, {
        'world',
    })

    -- test that return error with invalid code
    errlines = {}
    ok, res = exec('lua', {
        '-e',
        [[print(foo + 2)]],
    }, nil, nil, function(line)
        errlines[#errlines + 1] = line
    end)
    assert.is_false(ok)
    assert.match(res, concat(errlines, '\n'))
end

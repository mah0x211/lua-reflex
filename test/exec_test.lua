require('luacov')
local concat = table.concat
local testcase = require('testcase')
local exec = require('reflex.exec')

function testcase.exec()
    local outlines = {}
    local errlines = {}

    -- test that return true
    local ok, err = exec('lua', {
        '-e',
        [[io.stdout:write('hello'); io.stderr:write('world')]],
    }, nil, function(...)
        outlines[#outlines + 1] = concat({
            ...,
        }, ' ')
    end, function(line)
        errlines[#errlines + 1] = line
    end)
    assert(ok, err)
    assert.equal(outlines, {
        [[lua -e io.stdout:write('hello'); io.stderr:write('world')]],
        'hello',
    })
    assert.equal(errlines, {
        'world',
    })

    -- test that return error with invalid syntax
    ok, err = exec('lua', {
        '-e',
        [[print(']],
    })
    assert.is_false(ok)
    assert.match(err, 'unfinished string')

    -- test that return error with invalid code
    ok, err = exec('lua', {
        '-e',
        [[print(foo + 2)]],
    })
    assert.is_false(ok)
    assert.match(err, 'attempt to perform arithmetic')

    -- test that throws an error if invalid argument
    err = assert.throws(exec, 'lua', {
        '-v',
    }, nil, 1)
    assert.match(err, 'stdout must be function')

    err = assert.throws(exec, 'lua', {
        '-v',
    }, nil, nil, 1)
    assert.match(err, 'stderr must be function')
end

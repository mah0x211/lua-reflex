require('luacov')
local testcase = require('testcase')
local loadstring = require('loadchunk').string
local print = print
require('reflex.global')

function testcase.after_each()
    _G.print = print
end

function testcase.printv()
    local out = {}
    _G.print = function(...)
        local args = {
            ...,
        }
        for i = 1, select('#', ...) do
            out[#out + 1] = args[i]
        end
    end

    -- test that print dumped arguments
    printv({
        hello = 'world',
    }, 'foo', 1, {
        'bar',
        {},
    })
    _G.print = print
    -- confirm
    local fn = assert(loadstring('return ' .. out[1]))
    local res = assert(fn())
    assert.equal(res, {
        {
            hello = 'world',
        },
        'foo',
        1,
        {
            'bar',
            {},
        },
    })
end

function testcase.errorf()
    -- test that throw an error
    local err = assert.throws(errorf, 'hello')
    assert.equal(err, 'hello')

    -- test that change the error level witg the first argument
    err = assert.throws(errorf, 1, 'hello')
    assert.match(err, 'global.lua.+ hello', false)
end

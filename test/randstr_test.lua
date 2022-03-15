require('luacov')
local testcase = require('testcase')
local randstr = require('reflex.randstr')

function testcase.randstr()
    -- test that returns a specified length of random string
    for i = 1, 1000, 50 do
        local s = assert(randstr(i))
        assert.equal(#s, i)
        assert.match(s, '^%d+$', false)
    end
end

function testcase.randstr_with_encode()
    -- test that returns a specified length of random string
    for i = 1, 1000, 50 do
        local s = assert(randstr(i, true))
        assert.equal(#s, i)
        assert.match(s, '^[a-zA-Z0-9_%-]+$', false)
    end
end

require('luacov')
local testcase = require('testcase')
local randstr = require('reflex.randstr')

function testcase.randstr()
    -- test that returns a specified length of random string
    local tbl = {}
    for i = 1, 1000, 50 do
        local s = assert(randstr(i))
        assert.equal(#s, i)
        assert.is_nil(tbl[s])
        tbl[s] = 1
    end
end

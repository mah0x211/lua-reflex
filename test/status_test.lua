require('luacov')
local testcase = require('testcase')
local status = require('reflex.status')

function testcase.status()
    -- test that field names and values are correct
    for k, v in pairs(status) do
        local code

        if type(k) == 'string' then
            -- name/code pairs
            assert.match(k, '^[A-Z][A-Z_]*[A-Z]$', false)
            code = v
        elseif type(k) == 'number' then
            -- code/message pairs
            assert.equal(type(v), 'string')
            code = k
        end

        -- test that code is valid
        assert.match(tostring(code), '^%d+$', false)
        assert.greater_or_equal(code, 100)
        assert.less_or_equal(code, 599)
    end
end

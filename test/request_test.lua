require('luacov')
local testcase = require('testcase')
local new_request = require('reflex.request').new

function testcase.new()
    -- test that create a new request
    assert(new_request())
end


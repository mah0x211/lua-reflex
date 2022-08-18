require('luacov')
local testcase = require('testcase')
local new_http_request = require('net.http.message.request').new
local new_request = require('reflex.request')

function testcase.new()
    -- test that create a new request
    local req = new_http_request()
    assert(req:set_uri('.dot-file'))
    assert(new_request(req))
end


require('luacov')
local testcase = require('testcase')
local json = require('reflex.json')

function testcase.encode()
    -- test that encode to a string with newline
    local s = assert(json.encode({
        foo = 'bar',
    }))
    assert.match(s, '\n')
end

function testcase.encode_compact()
    -- test that encode to a string without newline
    local s = assert(json.encode_compact({
        foo = 'bar',
    }))
    assert.not_match(s, '\n')
end

function testcase.decode()
    -- test that decode to value without reference
    local v = assert(json.decode('{ "foo": "bar" }'))
    assert.is_nil(v[-1])
end

function testcase.decode_with_ref()
    -- test that decode to value with a object type reference
    local v = assert(json.decode_with_ref('{ "foo": "bar" }'))
    assert.match(v[-1], 'yyjson.as_object')
end

require('luacov')
local testcase = require('testcase')
local readcfg = require('reflex.readcfg')
local dump = require('dump')

local CONFIG_FILES = {
    ['tmp/invalid_openresty.lua'] = {
        openresty = {},
    },
    ['tmp/invalid_session.lua'] = {
        session = 'foo',
    },
    ['tmp/invalid_env.lua'] = {
        env = 'foo',
    },
}

function testcase.before_all()
    for filename, config in pairs(CONFIG_FILES) do
        local contents = {}
        for k, v in pairs(config) do
            contents[#contents + 1] = k .. ' = ' .. dump(v)
        end
        contents = table.concat(contents, '\n')
        local f = assert(io.open(filename, 'w+'))
        assert(f:write(contents))
        f:close()
    end
end

function testcase.after_all()
    for filename in pairs(CONFIG_FILES) do
        os.remove(filename)
    end
end

function testcase.read_default_config()
    -- test that return default config
    local cfg, loaded = readcfg()
    assert.equal(cfg.name, 'unknown')
    assert.is_false(loaded)

    -- test that throw an error if file not exist
    local err = assert.throws(readcfg, './testdir/config_not_exist.lua')
    assert.match(err, 'failed to load')

    -- test that throw an error if invalid file
    err = assert.throws(readcfg, './testdir/config_invalid.lua')
    assert.match(err, 'failed to evaluate')
end

function testcase.invalid_openresty()
    local err = assert.throws(readcfg, 'tmp/invalid_openresty.lua')
    assert.match(err, 'openresty must be string')
end

function testcase.invalid_session()
    local err = assert.throws(readcfg, 'tmp/invalid_session.lua')
    assert.match(err, 'session must be table')
end

function testcase.invalid_env()
    local err = assert.throws(readcfg, 'tmp/invalid_env.lua')
    assert.match(err, 'env must be table')
end


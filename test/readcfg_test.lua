require('luacov')
local testcase = require('testcase')
local readcfg = require('reflex.readcfg')

function testcase.readcfg()
    -- test that return default config
    local cfg, loaded = readcfg()
    assert.equal(cfg.name, 'unknown')
    assert.is_false(loaded)

    -- test that return loaded config
    cfg, loaded = readcfg('./testdir/config.lua')
    assert.equal(cfg.name, 'hello_world')
    assert.is_true(loaded)

    -- test that throw an error if file not exist
    local err = assert.throws(readcfg, './testdir/config_not_exist.lua')
    assert.match(err, 'failed to load')

    -- test that throw an error if invalid file
    err = assert.throws(readcfg, './testdir/config_invalid.lua')
    assert.match(err, 'failed to evaluate')
end

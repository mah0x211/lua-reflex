require('luacov')
local format = require('print').format
local testcase = require('testcase')
local getopts = require('reflex.getopts')

local EXIT = os.exit
local PRINT = _G.print

local function dummy_exit()
    error('getopts_exit')
end

local OUTPUT
local function dummy_print(...)
    if type(OUTPUT) ~= 'table' then
        OUTPUT = {}
    end
    OUTPUT[#OUTPUT + 1] = format(...) .. '\n'
end

local function set_dummy_funcs()
    -- Setting a read-only global variable.
    -- luacheck: ignore os
    os.exit = dummy_exit
    _G.print = dummy_print
end

local function unset_dummy_funcs()
    -- Setting a read-only global variable.
    -- luacheck: ignore os
    os.exit = EXIT
    _G.print = PRINT
end

function testcase.after_each()
    OUTPUT = nil
    unset_dummy_funcs()
end

function testcase.getopts()
    -- test that parse argument
    local opts = getopts({
        '-t',
        '--foo=bar',
        'value',
    }, {
        ['-t'] = {
            name = 'flag',
            desc = 'flag',
        },
        ['--foo'] = {
            pair = 'value',
            desc = 'key=value pair option',
        },
    })
    assert.equal(opts, {
        'value',
        flag = true,
        foo = 'bar',
    })

    -- test that throws an error if invalid argument
    local err = assert.throws(getopts, nil)
    assert.match(err, 'args must be table')

    -- test that throws an error if file could not open
    err = assert.throws(getopts, {}, true)
    assert.match(err, 'opts must be table')
end

function testcase.unknown_opt()
    -- test that throw an usage message if got an unknown option
    set_dummy_funcs()
    local err = assert.throws(getopts, {
        '-t',
    }, {})
    unset_dummy_funcs()
    assert.match(err, 'getopts_exit')
    assert.match(table.concat(OUTPUT), 'invalid option: "-t"')
end

function testcase.invalid_single_opt_format()
    -- test that throw an usage message if invalid single option format
    set_dummy_funcs()
    local err = assert.throws(getopts, {
        '--foo=bar',
    }, {
        ['--foo'] = {},
    })
    unset_dummy_funcs()
    assert.match(err, 'getopts_exit')
    assert.match(table.concat(OUTPUT), 'must be passed with "--foo" format')

end

function testcase.invalid_pair_opt_format()
    -- test that throw an usage message if invalid pair option format
    set_dummy_funcs()
    local err = assert.throws(getopts, {
        '--foo',
    }, {
        ['--foo'] = {
            pair = 'bar',
        },
    })
    unset_dummy_funcs()
    assert.match(err, 'getopts_exit')
    assert.match(table.concat(OUTPUT),
                 'must be passed with "--foo=<bar>" format')
end

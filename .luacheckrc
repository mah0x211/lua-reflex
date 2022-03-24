std = 'max'
read_globals = {
    'printv',
    assert = {
        fields = {
            'empty',
            'equal',
            'greater',
            'greater_or_equal',
            'is_boolean',
            'is_false',
            'is_file',
            'is_finite',
            'is_function',
            'is_int',
            'is_int16',
            'is_int32',
            'is_int8',
            'is_nan',
            'is_nil',
            'is_none',
            'is_number',
            'is_string',
            'is_table',
            'is_thread',
            'is_true',
            'is_uint',
            'is_uint16',
            'is_uint32',
            'is_uint8',
            'is_unsigned',
            'is_userdata',
            'less',
            'less_or_equal',
            'match',
            'not_empty',
            'not_equal',
            'not_match',
            'not_rawequal',
            'not_re_match',
            'rawequal',
            're_match',
            'throws',
            'torawstring',
        },
    },
    print = {
        fields = {
            'flush',
            'format',
            'setdebug',
            'setlevel',
            'emerge',
            'alert',
            'crit',
            'error',
            'warn',
            'notice',
            'info',
        },
    },
}
include_files = {
    'bin/*.lua',
    'lib/**/*.lua',
    'test/*_test.lua',
}
ignore = {
    'assert',
    -- unused argument
    '212',
    -- line is too long.
    '631',
}

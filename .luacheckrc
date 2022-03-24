std = 'max'
read_globals = {
    'printv',
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

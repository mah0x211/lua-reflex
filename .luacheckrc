std = 'max+ngx_lua'
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

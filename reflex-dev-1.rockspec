rockspec_format = '3.0'
package = 'reflex'
version = 'dev-1'
source = {
    url = 'git+https://github.com/mah0x211/lua-fsrouter.git',
}
description = {
    summary = '',
    homepage = 'https://github.com/mah0x211/lua-reflex',
    license = 'MIT/X11'
}
dependencies = {
    'lua >= 5.1',
    'assert >= 0.3.4',
    'basedir >= 0.3.0',
    'dump >= 0.1.1',
    'error >= 0.6.2',
    'exec >= 0.2.0',
    'fsrouter >= 0.4.0',
    'getcwd >= 0.1.0',
    'getenv >= 0.2.1',
    'loadchunk >= 0.1.2',
    'print >= 0.1.0',
    'rez == 0.4.0',
    'stringex >= 0.2.1',
    'unpack >= 0.1.0',
    'url >= 1.3.1',
    'yyjson >= 0.4.0',
}
build = {
    type = 'builtin',
    modules = {
        ['reflex.fs'] = 'lib/fs.lua',
        ['reflex.exec'] = 'lib/exec.lua',
        ['reflex.global'] = 'lib/global.lua',
        ['reflex.install'] = 'lib/install.lua',
        ['reflex.readcfg'] = 'lib/readcfg.lua',
        ['reflex.renderer'] = 'lib/renderer.lua',
        ['reflex.router'] = 'lib/router.lua',
        ['reflex.status'] = 'lib/status.lua',
    },
}

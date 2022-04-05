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
    'base64mix >= 1.0.0',
    'basedir >= 0.3.0',
    'cookie >= 1.3.0',
    'dump >= 0.1.1',
    'error >= 0.6.2',
    'exec >= 0.2.0',
    'fsrouter >= 0.4.0',
    'getcwd >= 0.1.0',
    'getenv >= 0.2.1',
    'hmac >= 0.1.0',
    'loadchunk >= 0.1.2',
    'metamodule >= 0.3.1',
    'ossp-uuid >= 1.6.2',
    'print >= 0.1.0',
    'rez >= 0.5.1',
    'setenv >= 0.1.0',
    'stringex >= 0.2.2',
    'unpack >= 0.1.0',
    'url >= 1.3.1',
    'yyjson >= 0.4.0',
}
build = {
    type = 'builtin',
    modules = {
        ['reflex.cache'] = 'lib/cache.lua',
        ['reflex.exec'] = 'lib/exec.lua',
        ['reflex.env'] = 'lib/env.lua',
        ['reflex.errorf'] = 'lib/errorf.lua',
        ['reflex.fs'] = 'lib/fs.lua',
        ['reflex.getopts'] = 'lib/getopts.lua',
        ['reflex.header'] = 'lib/header.lua',
        ['reflex.install'] = 'lib/install.lua',
        ['reflex.json'] = 'lib/json.lua',
        ['reflex.randstr'] = 'lib/randstr.lua',
        ['reflex.readcfg'] = 'lib/readcfg.lua',
        ['reflex.renderer'] = 'lib/renderer.lua',
        ['reflex.response'] = 'lib/response.lua',
        ['reflex.router'] = 'lib/router.lua',
        ['reflex.session'] = 'lib/session.lua',
        ['reflex.status'] = 'lib/status.lua',
        ['reflex.token'] = 'lib/token.lua',
    },
}

rockspec_format = "3.0"
package = "reflex"
version = "dev-1"
source = {
    url = "git+https://github.com/mah0x211/lua-reflex.git",
}
description = {
    summary = "A simple web framework for lua",
    homepage = "https://github.com/mah0x211/lua-reflex",
    license = "MIT/X11",
    maintainer = "Masatoshi Fukunaga",
}
dependencies = {
    "lua >= 5.1",
    "act >= 0.11",
    "assert >= 0.3.4",
    "base64mix >= 1.0.0",
    "basedir >= 0.4.0",
    "cache >= 1.3.0",
    "context >= 0.1.0",
    "cookie >= 1.3.0",
    "dump >= 0.1.1",
    "error >= 0.6.2",
    "exec >= 0.2.3",
    "exists >= 0.1.0",
    "fsrouter >= 0.5.0",
    "getcwd >= 0.2.0",
    "gpoll >= 0.2.0",
    "hmac >= 0.1.0",
    "io-fopen >= 0.1.3",
    "isa >= 0.3.0",
    "kvpairs >= 0.1.0",
    "libmagic >= 5.41.1",
    "loadchunk >= 0.1.2",
    "mediatypes >= 2.0.1",
    "metamodule >= 0.4.0",
    "net-http >= 0.2.0",
    "ossp-uuid >= 1.6.2",
    "print >= 0.3.0",
    "rez >= 0.5.3",
    "setenv >= 0.1.0",
    "signal >= 1.5.0",
    "string-capitalize >= 0.2.0",
    "string-contains >= 0.1.0",
    "string-random >= 0.1.0",
    "string-split >= 0.3.0",
    "string-trim >= 0.2.0",
    "unpack >= 0.1.0",
    "url >= 2.1.0",
    "yyjson >= 0.5.0",
}
build = {
    type = "builtin",
    install = {
        bin = {
            reflex = "bin/reflex.lua",
        },
    },
    modules = {
        ["reflex"] = "lib/reflex.lua",
        ["reflex.date"] = "lib/date.lua",
        ["reflex.errorf"] = "lib/errorf.lua",
        ["reflex.exec"] = "lib/exec.lua",
        ["reflex.fetch"] = "lib/fetch.lua",
        ["reflex.fs"] = "lib/fs.lua",
        ["reflex.getopts"] = "lib/getopts.lua",
        ["reflex.header"] = "lib/header.lua",
        ["reflex.install"] = "lib/install.lua",
        ["reflex.log"] = "lib/log.lua",
        ["reflex.mime"] = "lib/mime.lua",
        ["reflex.readcfg"] = "lib/readcfg.lua",
        ["reflex.renderer"] = "lib/renderer.lua",
        ["reflex.request"] = "lib/request.lua",
        ["reflex.response"] = "lib/response.lua",
        ["reflex.router"] = "lib/router.lua",
        ["reflex.session"] = "lib/session.lua",
        ["reflex.status"] = "lib/status.lua",
        ["reflex.token"] = "lib/token.lua",
    },
}

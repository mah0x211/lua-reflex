--
-- Copyright (C) 2022 Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
local pcall = pcall
local loadfile = require('loadchunk').file
local errorf = require('reflex.errorf')

--- readconf
--- @return table<string, any> cfg
--- @return boolean loaded
local function readcfg(pathname)
    local cfg = {
        name = 'unknown',
        version = '0.0.0',
    }

    -- return default config
    if not pathname then
        return cfg, false
    end

    -- load config file
    local fn, err = loadfile(pathname, cfg)
    if err then
        errorf('failed to load %q: %s', pathname, err)
    end

    local ok
    ok, err = pcall(fn)
    if not ok then
        errorf('failed to evaluate %q: %s', pathname, err)
    end

    return cfg, true
end

return readcfg

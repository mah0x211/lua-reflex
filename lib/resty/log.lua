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
local getinfo = debug.getinfo
local format = require('print').format

-- append call info
local function vformat(...)
    local info = getinfo(3, 'Sl')
    return format('[%s:%d] ', info.short_src, info.currentline) .. format(...)
end

local function log_stderr(...)
    ngx.log(ngx.STDERR, vformat(...))
end

local function log_emerg(...)
    ngx.log(ngx.EMERG, vformat(...))
end

local function log_alert(...)
    ngx.log(ngx.ALERT, vformat(...))
end

local function log_crit(...)
    ngx.log(ngx.CRIT, vformat(...))
end

local function log_error(...)
    ngx.log(ngx.ERR, vformat(...))
end

local function log_warn(...)
    ngx.log(ngx.WARN, vformat(...))
end

local function log_notice(...)
    ngx.log(ngx.NOTICE, vformat(...))
end

local function log_info(...)
    ngx.log(ngx.INFO, vformat(...))
end

local function log_debug(...)
    ngx.log(ngx.DEBUG, vformat(...))
end

return {
    emerg = log_emerg,
    alert = log_alert,
    crit = log_crit,
    error = log_error,
    warn = log_warn,
    notice = log_notice,
    info = log_info,
    stderr = log_stderr,
    debug = log_debug,
}

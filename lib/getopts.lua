--
-- Copyright (C) 2021 Masatoshi Fukunaga
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
local concat = table.concat
local sort = table.sort
local ipairs = ipairs
local string = require('stringex')
local has_prefix = string.has_prefix
local split = string.split
local match = string.match
local isa = require('isa')
local is_table = isa.table
local is_string = isa.string
local format = require('print').format

local function print_pair_opt(opts, fmt)
    local list = {}
    for k, v in pairs(opts) do
        if is_string(k) and is_string(v.pair) then
            list[#list + 1] = {
                key = k,
                desc = format(fmt, k .. '=' .. v.pair, v.desc or ''),
            }
        end
    end

    sort(list, function(a, b)
        return a.key < b.key
    end)
    for _, v in ipairs(list) do
        print(v.desc)
    end
end

local function print_single_opt(opts, fmt)
    local list = {}
    for k, v in pairs(opts) do
        if is_string(k) and not is_string(v.pair) then
            list[#list + 1] = {
                key = k,
                desc = format(fmt, k, v.desc or ''),
            }
        end
    end

    sort(list, function(a, b)
        return a.key < b.key
    end)
    for _, v in ipairs(list) do
        print(v.desc)
    end
end

local function get_pair_opt_keys(opts, maxklen)
    local list = {}
    for k, v in pairs(opts) do
        if is_string(k) and is_string(v.pair) then
            list[#list + 1] = format('[%s=%s]', k, v.pair)
            k = format('%s %s', k, v.pair)
            if maxklen < #k then
                maxklen = #k
            end
        end
    end
    return concat(list, ' '), maxklen
end

local function get_single_opt_keys(opts, maxklen)
    local list = {}
    for k, v in pairs(opts) do
        if is_string(k) and not is_string(v.pair) then
            list[#list + 1] = format('[%s]', k)
            if maxklen < #k then
                maxklen = #k
            end
        end
    end
    return concat(list, ' '), maxklen
end

local function usage(opts, err)
    local skeys, maxsklen = get_single_opt_keys(opts, 0)
    local pkeys, maxklen = get_pair_opt_keys(opts, maxsklen)

    if err then
        print(err, '\n')
    end
    print(format([[
Usage:
  reflex %s %s
]], skeys, pkeys))

    print('Options:')
    local fmt = '  %-' .. maxklen .. 's : %s'
    print_single_opt(opts, fmt)
    print_pair_opt(opts, fmt)
    print('')
    os.exit(-1)
end

--- getopts
--- @param args string[]
--- @param opts table
--- @return table
local function getopts(args, opts)
    opts = opts or {}
    if not is_table(args) then
        error('args must be table', 2)
    elseif not is_table(opts) then
        error('opts must be table', 2)
    end

    local vals = {}
    for _, s in ipairs(args) do
        if not has_prefix(s, '-') then
            vals[#vals + 1] = s
        else
            local arr = split(s, '=', false, 1)
            local opt = opts[arr[1]]
            local key = match(arr[1], '^-*(.+)$')

            if not opt then
                usage(opts, format('invalid option: %q', s))
            end

            if is_string(opt.pair) then
                if #arr == 1 then
                    usage(opts,
                          format(
                              'invalid option %q: must be passed with %q format',
                              s, format('%s=<%s>', arr[1], opt.pair)))
                end
                vals[opt.name or key] = arr[2]
            elseif #arr > 1 then
                usage(opts, format(
                          'invalid option %q: must be passed with %q format', s,
                          arr[1]))
            elseif opt.help then
                usage(opts)
            else
                vals[opt.name or key] = true
            end
        end
    end

    return vals
end

return getopts

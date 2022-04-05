local concat = table.concat
local popen = io.popen
local find = string.find
local format = string.format
local match = string.match
local type = type

--- which
--- @param filename string
--- @return string pathname
local function which(filename)
    if type(filename) ~= 'string' then
        error('filename must be string', 2)
    end

    local errors = {}
    local cmds = {
        'type -p %q 2>&1',
        'which %q 2>&1',
    }
    for _, cmd in ipairs(cmds) do
        local f = popen(format(cmd, filename))
        local res = f:read('*a')
        f:close()

        if #res > 0 then
            local pathname = match(res, '^%s*([^%s]+)%s*$')
            if pathname and not find(pathname, '%s') then
                return pathname
            end
            errors[#errors + 1] = match(res, '^(.+)%s+$')
        end
    end

    if #errors == #cmds then
        error(concat(errors, ', '), 2)
    end
end

return which

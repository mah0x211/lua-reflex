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
local lower = string.lower
local open = io.open
local pairs = pairs
local setmetatable = setmetatable
local new_header = require('reflex.header').new

-- constants
local CONTEXT_ID = 'request.ctx'

--- @class Request
--- @field method string
--- @field scheme string
--- @field uri string
--- @field request_uri string
--- @field query table<string, any>
--- @field header Header
--- @field errors string[]
--- @field session Session?
local Request = {}
Request.__index = Request

--- push_error
--- @param err string
function Request:push_error(err)
    self.errors[#self.errors + 1] = err
end

--- get_errors
--- @param err string[]
function Request:get_errors(err)
    return self.errors
end

--- get_body_data
--- @return string body
--- @return string err
function Request:get_body_data()
    ngx.req.read_body()
    local data = ngx.req.get_body_data()
    if data then
        return data
    end

    local filename = ngx.req.get_body_file()
    if not filename then
        return nil
    end

    local f = open(filename)
    if f then
        data = f:read('*a')
        f:close()
        return data
    end
end

--- get_body
--- @return table<string, string[]> body
--- @return string err
function Request:get_body()
    ngx.req.read_body()
    return ngx.req.get_post_args()
end

--- new
--- @return Request req
--- @return string err
local function new()
    local req = ngx.ctx['request.ctx']
    local header = new_header()
    for k, v in pairs(ngx.req.get_headers()) do
        header:set(k, v)
    end

    if not req then
        -- create new request/responder pair
        req = setmetatable({
            addr = ngx.var.remote_addr .. ':' .. ngx.var.remote_port,
            method = lower(ngx.req.get_method()),
            scheme = ngx.var.scheme,
            uri = ngx.var.uri,
            request_uri = ngx.var.request_uri,
            query = ngx.req.get_uri_args(),
            header = header,
            errors = {},
        }, Request)
        ngx.ctx[CONTEXT_ID] = req
    end

    return req
end

return {
    new = new,
}


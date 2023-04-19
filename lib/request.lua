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
local concat = table.concat
local pairs = pairs
local sub = string.sub
local new_kvpairs = require('kvpairs').new
local parse_cookie = require('cookie').parse
local log = require('reflex.log')
local new_session = require('reflex.session').new

--- @class reflex.request : net.http.message.request
--- @field method string
--- @field uri string
--- @field header net.http.header
--- @field content? net.http.content
--- @field sess reflex.session
--- @field cookies? table<string, string>
local Request = {}

--- init
--- @param req net.http.message.request
--- @return reflex.request req
function Request:init(req)
    -- wrap
    for k, v in pairs(req) do
        -- ignore underscore prefixed keys
        if sub(k, 1, 1) ~= '_' then
            self[k] = v
        end
    end

    local kvp = new_kvpairs()
    if self.query_params then
        kvp.dict = self.query_params
        self.rawquery = self.query
        self.query_params = nil
    end
    self.query = kvp

    return self
end

--- parse_cookies
function Request:parse_cookies()
    if type(self.cookies) ~= 'table' then
        self.cookies = {}
        local list = self.header:get('Cookie', true)
        if list then
            self.cookies = parse_cookie(concat(list, '; '))
        end
    end
end

--- session
--- @param restore_only boolean
--- @return reflex.session? sess
--- @return any err
function Request:session(restore_only)
    if self.sess then
        return self.sess
    end

    -- start session
    self:parse_cookies()
    local sess, err = new_session(self.cookies, restore_only)
    if err then
        log.error('failed to create new session:', err)
        return nil, err
    elseif sess then
        self.sess = sess
    end
    return sess
end

--- save_session
--- @return string? cookie
--- @return any err
function Request:save_session()
    if self.sess then
        local cookie, err = self.sess:save()
        if err then
            log.error('failed to save session:', err)
            return nil, err
        end
        return cookie
    end
end

Request = require('metamodule').new(Request, 'net.http.message.request')

return Request


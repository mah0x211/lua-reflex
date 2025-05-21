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
local errorf = require('error').format
local verify_token = require('reflex.token').verify
local new_session = require('reflex.session').new
local get_cookie_config = require('reflex.session').get_cookie_config
local restore_session = require('reflex.session').restore

--- @class reflex.request : net.http.message.request
--- @field sess session.Session?
--- @field cookies? table<string, string>
--- @field params? table
--- @field route_uri? string
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

--- verify_csrf_cookie
--- @return boolean ok
function Request:verify_csrf_cookie()
    self:parse_cookies()
    local name = 'X-CSRF-Token'
    local token = self.cookies[name]
    if token then
        return verify_token(name, token)
    end
    return false
end

--- session
--- @param restore_only boolean
--- @return session.Session? sess
--- @return any err
function Request:session(restore_only)
    assert(restore_only == nil or type(restore_only) == 'boolean',
           'restore_only must be boolean')

    if self.sess then
        return self.sess
    end

    -- start session
    self:parse_cookies()
    local sid = self.cookies and self.cookies[get_cookie_config('name')]
    if sid then
        local sess, err, timeout = restore_session(sid)
        if err then
            return nil, errorf('failed to restore session', err)
        elseif timeout then
            return nil, errorf('failed to restore session: request timed out')
        elseif sess then
            self.sess = sess
            return sess
        end
    end

    if not restore_only then
        -- create new session
        self.sess = new_session()
        return self.sess
    end
end

--- save_session if session is nil then return nil without error
--- @return string? cookie
--- @return any err
function Request:save_session()
    if self.sess then
        local cookie, err, timeout = self.sess:save()
        if err then
            return nil, errorf('failed to save session', err)
        elseif timeout then
            return nil, errorf('failed to save session: request timed out')
        end
        return cookie
    end
end

Request = require('metamodule').new(Request, 'net.http.message.request')

return Request


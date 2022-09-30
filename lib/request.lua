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
local Request = {}

--- init
--- @param req net.http.message.request
--- @return reflex.request req
function Request:init(req)
    -- wrap
    for k, v in pairs(req) do
        self[k] = v
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

--- session
--- @param restore_only boolean
--- @return reflex.session? sess
function Request:session(restore_only)
    if self.sess then
        return self.sess
    end

    -- start session
    local cookies = self.header:get('Cookie', true)
    if cookies then
        -- NOTE: ignore invalid cookie header
        cookies = parse_cookie(concat(cookies, '; '))
    end

    local sess, err = new_session(cookies, restore_only)
    if sess then
        self.sess = sess
        return sess
    elseif err then
        log.fatal('failed to create session: %s', err)
    end
end

--- save_session
--- @return string? cookie
function Request:save_session()
    if self.sess then
        local cookie, err = self.sess:save()
        if not cookie then
            log.fatal('failed to save session: %s', err)
        end
        return cookie
    end
end

Request = require('metamodule').new(Request, 'net.http.message.request')

return Request


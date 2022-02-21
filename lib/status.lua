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
local gsub = string.gsub
local pairs = pairs
local upper = string.upper

local Status = {}

for code, msg in pairs({
    -- 1xx infromational
    [100] = 'Continue',
    [101] = 'Switching Protocols',
    -- WebDAV
    [102] = 'Processing', -- WebDAV; RFC 2518
    -- /WebDAV

    -- 2xx successful
    [200] = 'OK',
    [201] = 'Created',
    [202] = 'Accepted',
    [203] = 'Non-Authoritative Information', -- since HTTP/1.1
    [204] = 'No Content',
    [205] = 'Reset Content',
    [206] = 'Partial Content',
    -- WebDAV
    [207] = 'Multi-Status', -- WebDAV; RFC 4918
    [208] = 'Already Reported', -- WebDAV; RFC 5842
    -- /WebDAV
    [226] = 'IM Used', -- RFC 3229

    -- 3xx redirect
    [300] = 'Multiple Choices',
    [301] = 'Moved Permanently',
    [302] = 'Found',
    [303] = 'See Other', -- since HTTP/1.1
    [304] = 'Not Modified',
    [305] = 'Use Proxy', -- since HTTP/1.1
    [307] = 'Temporary Redirect', -- since HTTP/1.1
    [308] = 'Permanent Redirect', -- Experimental; RFC 7238

    -- 4xx client error
    [400] = 'Bad Request',
    [401] = 'Unauthorized',
    [402] = 'Payment Required',
    [403] = 'Forbidden',
    [404] = 'Not Found',
    [405] = 'Method Not Allowed',
    [406] = 'Not Acceptable',
    [407] = 'Proxy Authentication Required',
    [408] = 'Request Timeout',
    [409] = 'Conflict',
    [410] = 'Gone',
    [411] = 'Length Required',
    [412] = 'Precondition Failed',
    [413] = 'Request Entity Too Large',
    [414] = 'Request-URI Too Long',
    [415] = 'Unsupported Media Type',
    [416] = 'Requested Range Not Satisfiable',
    [417] = 'Expectation Failed',
    -- WebDAV
    [422] = 'Unprocessable Entity', -- WebDAV; RFC 4918
    [423] = 'Locked', -- WebDAV; RFC 4918
    [424] = 'Failed Dependency', -- WebDAV; RFC 4918
    -- /WebDAV
    [426] = 'Upgrade Required', -- RFC 2817
    [428] = 'Precondition Required', -- RFC 6585
    [429] = 'Too Many Requests', -- RFC 6585
    [431] = 'Request Header Fields Too Large', -- RFC 6585
    [451] = 'Unavailable For Legal Reasons', -- Internet draft

    -- 5xx server error
    [500] = 'Internal Server Error',
    [501] = 'Not Implemented',
    [502] = 'Bad Gateway',
    [503] = 'Service Unavailable',
    [504] = 'Gateway Timeout',
    [505] = 'HTTP Version Not Supported',
    [506] = 'Variant Also Negotiates', -- RFC 2295
    -- WebDAV
    [507] = 'Insufficient Storage', -- WebDAV; RFC 4918
    [508] = 'Loop Detected', -- WebDAV; RFC 5842
    -- /WebDAV
    [510] = 'Not Extended', -- RFC 2774
    [511] = 'Network Authentication Required', -- RFC 6585
}) do
    Status[code] = msg
    -- convert lowercase to uppercase and space and hyphen to underscore
    local name = gsub(upper(msg), '[- ]', {
        [' '] = '_',
        ['-'] = '_',
    })
    Status[name] = code
end

return Status

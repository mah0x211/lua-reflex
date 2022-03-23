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
return {
    -- 1xx infromational
    CONTINUE = 100,
    [100] = 'Continue',
    SWITCHING_PROTOCOLS = 101,
    [101] = 'Switching Protocols',
    -- WebDAV
    PROCESSING = 102,
    [102] = 'Processing', -- WebDAV; RFC 2518
    -- /WebDAV

    -- 2xx successful
    OK = 200,
    [200] = 'OK',
    CREATED = 201,
    [201] = 'Created',
    ACCEPTED = 202,
    [202] = 'Accepted',
    NON_AUTHORITATIVE_INFORMATION = 203,
    [203] = 'Non-Authoritative Information', -- since HTTP/1.1
    NO_CONTENT = 204,
    [204] = 'No Content',
    RESET_CONTENT = 205,
    [205] = 'Reset Content',
    PARTIAL_CONTENT = 206,
    [206] = 'Partial Content',
    -- WebDAV
    MULTI_STATUS = 207,
    [207] = 'Multi-Status', -- WebDAV; RFC 4918
    ALREADY_REPORTED = 208,
    [208] = 'Already Reported', -- WebDAV; RFC 5842
    -- /WebDAV
    IM_USED = 226,
    [226] = 'IM Used', -- RFC 3229

    -- 3xx redirect
    MULTIPLE_CHOICES = 300,
    [300] = 'Multiple Choices',
    MOVED_PERMANENTLY = 301,
    [301] = 'Moved Permanently',
    FOUND = 302,
    [302] = 'Found',
    SEE_OTHER = 303,
    [303] = 'See Other', -- since HTTP/1.1
    NOT_MODIFIED = 304,
    [304] = 'Not Modified',
    USE_PROXY = 305,
    [305] = 'Use Proxy', -- since HTTP/1.1
    TEMPORARY_REDIRECT = 307,
    [307] = 'Temporary Redirect', -- since HTTP/1.1
    PERMANENT_REDIRECT = 308,
    [308] = 'Permanent Redirect', -- Experimental; RFC 7238

    -- 4xx client error
    BAD_REQUEST = 400,
    [400] = 'Bad Request',
    UNAUTHORIZED = 401,
    [401] = 'Unauthorized',
    PAYMENT_REQUIRED = 402,
    [402] = 'Payment Required',
    FORBIDDEN = 403,
    [403] = 'Forbidden',
    NOT_FOUND = 404,
    [404] = 'Not Found',
    METHOD_NOT_ALLOWED = 405,
    [405] = 'Method Not Allowed',
    NOT_ACCEPTABLE = 406,
    [406] = 'Not Acceptable',
    PROXY_AUTHENTICATION_REQUIRED = 407,
    [407] = 'Proxy Authentication Required',
    REQUEST_TIMEOUT = 408,
    [408] = 'Request Timeout',
    CONFLICT = 409,
    [409] = 'Conflict',
    GONE = 410,
    [410] = 'Gone',
    LENGTH_REQUIRED = 411,
    [411] = 'Length Required',
    PRECONDITION_FAILED = 412,
    [412] = 'Precondition Failed',
    REQUEST_ENTITY_TOO_LARGE = 413,
    [413] = 'Request Entity Too Large',
    REQUEST_URI_TOO_LONG = 414,
    [414] = 'Request-URI Too Long',
    UNSUPPORTED_MEDIA_TYPE = 415,
    [415] = 'Unsupported Media Type',
    REQUESTED_RANGE_NOT_SATISFIABLE = 416,
    [416] = 'Requested Range Not Satisfiable',
    EXPECTATION_FAILED = 417,
    [417] = 'Expectation Failed',
    -- WebDAV
    UNPROCESSABLE_ENTITY = 422,
    [422] = 'Unprocessable Entity', -- WebDAV; RFC 4918
    LOCKED = 423,
    [423] = 'Locked', -- WebDAV; RFC 4918
    FAILED_DEPENDENCY = 424,
    [424] = 'Failed Dependency', -- WebDAV; RFC 4918
    -- /WebDAV
    UPGRADE_REQUIRED = 426,
    [426] = 'Upgrade Required', -- RFC 2817
    PRECONDITION_REQUIRED = 428,
    [428] = 'Precondition Required', -- RFC 6585
    TOO_MANY_REQUESTS = 429,
    [429] = 'Too Many Requests', -- RFC 6585
    REQUEST_HEADER_FIELDS_TOO_LARGE = 431,
    [431] = 'Request Header Fields Too Large', -- RFC 6585
    UNAVAILABLE_FOR_LEGAL_REASONS = 451,
    [451] = 'Unavailable For Legal Reasons', -- Internet draft

    -- 5xx server error
    INTERNAL_SERVER_ERROR = 500,
    [500] = 'Internal Server Error',
    NOT_IMPLEMENTED = 501,
    [501] = 'Not Implemented',
    BAD_GATEWAY = 502,
    [502] = 'Bad Gateway',
    SERVICE_UNAVAILABLE = 503,
    [503] = 'Service Unavailable',
    GATEWAY_TIMEOUT = 504,
    [504] = 'Gateway Timeout',
    HTTP_VERSION_NOT_SUPPORTED = 505,
    [505] = 'HTTP Version Not Supported',
    VARIANT_ALSO_NEGOTIATES = 506,
    [506] = 'Variant Also Negotiates', -- RFC 2295
    -- WebDAV
    INSUFFICIENT_STORAGE = 507,
    [507] = 'Insufficient Storage', -- WebDAV; RFC 4918
    LOOP_DETECTED = 508,
    [508] = 'Loop Detected', -- WebDAV; RFC 5842
    -- /WebDAV
    NOT_EXTENDED = 510,
    [510] = 'Not Extended', -- RFC 2774
    NETWORK_AUTHENTICATION_REQUIRED = 511,
    [511] = 'Network Authentication Required', -- RFC 6585
}

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
return [=[
#
# this configuration is based on https://github.com/denji/nginx-tuning
#

daemon on;

error_log logs/error.log notice;

# you must set worker processes based on your CPU cores, nginx does not benefit
# from setting more than that
worker_processes auto;

# number of file descriptors used for nginx
# the limit for the maximum FDs on the server is usually set by the OS.
# if you don't set FD's then OS settings will be used which is by default 2000
worker_rlimit_nofile 100000;

# provides the configuration file context in which the directives that affect
# connection processing are specified.
events {
    # determines how much clients will be served per worker
    #
    #   max clients = worker_connections * worker_processes
    #
    # max clients is also limited by the number of socket connections available
    # on the system (~64k)
    worker_connections 4000;

    # @testing environment
    # accept as many connections as possible, may flood worker connections if
    # set too low
    multi_accept on;
}


http {
    #
    # @ content handling settings
    #
    root            html;
    default_type    text/html;
    include         mime.types;
    index           index.html index.json;
    sendfile        on;
    #
    # cache informations about FDs, frequently accessed files
    # can boost performance, but you need to test those values
    #
    open_file_cache max=200000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    #
    # for testing environment
    # reduce the data that needs to be sent over network
    #
    gzip            on;
    gzip_min_length 10240;
    gzip_comp_level 1;
    gzip_vary       on;
    gzip_disable    msie6;
    gzip_proxied    expired no-cache no-store private auth;
    gzip_types
        # text/html is always compressed by HttpGzipModule
        text/css
        text/javascript
        text/xml
        text/plain
        text/x-component
        application/javascript
        application/x-javascript
        application/json
        application/xml
        application/rss+xml
        application/atom+xml
        font/truetype
        font/opentype
        application/vnd.ms-fontobject
        image/svg+xml;

    #
    # @ client handling settings
    #
    #
    # client buffering
    #
    tcp_nopush                  on;
    tcp_nodelay                 on;
    client_header_buffer_size   4k;
    client_body_buffer_size     16k;
    client_max_body_size        128k;
    #
    # timeout
    #
    reset_timedout_connection   on;
    client_header_timeout       5s;
    client_body_timeout         15s;
    send_timeout                30s;
    #
    # keepalive
    #
    keepalive_requests  100000;
    keepalive_timeout   15;
    #
    # resolver
    #
    resolver            '8.8.8.8';
    resolver_timeout    5s;

    #
    # @ log settings
    # http://nginx.org/en/docs/http/ngx_http_core_module.html#variables
    #
    access_log  logs/access.log;


    #
    # @ openresty settings
    #
    lua_code_cache          on;
    #
    # shared memory
    #
    # default session dictionary
    lua_shared_dict reflex_sesdict 10m; # DO NOT DELETE THIS DIRECTIVE

    #
    # regex
    #
    lua_regex_cache_max_entries 1024;
    lua_regex_match_limit       0;
    #
    # timer
    #
    lua_max_pending_timers  1024;
    lua_max_running_timers  256;
    #
    # lua socket
    #
    lua_socket_buffer_size          32k;
    lua_socket_pool_size            30;
    lua_socket_keepalive_timeout    15s;
    lua_socket_connect_timeout      5s;
    lua_socket_send_timeout         10s;
    lua_socket_read_timeout         10s;
    lua_socket_log_errors           on;
    #
    # request I/O
    #
    lua_use_default_type    on;
    lua_need_request_body   off;
    lua_check_client_abort  on;
    lua_transform_underscores_in_response_headers   on;
    #
    # phase priority setting
    #
    rewrite_by_lua_no_postpone  off;
    access_by_lua_no_postpone   off;

    #
    # initialize script
    #
    init_by_lua_block {
        Resty = require("reflex.resty").new()
    }
    init_worker_by_lua_block {
        Resty:init_worker()
    }

    server {
        listen 127.0.0.1:8080;
        #
        # @ ssl settings
        #
        #listen                      127.0.0.1:8443;
        #ssl_certificate             cert/cert.pem;
        #ssl_certificate_key         cert/cert.key;
        #ssl_dhparam                 cert/dhparam;
        #ssl_session_tickets         off;
        #ssl_session_cache           shared:SSL:5m;
        #ssl_session_timeout         5m;
        #ssl_protocols               TLSv1.2 TLSv1.3;
        #ssl_prefer_server_ciphers   on;
        #ssl_ciphers                 HIGH:!aNULL:!MD5;

        log_by_lua_block {
            Resty:log()
        }

        location / {
            content_by_lua_block {
                Resty:serve()
            }
        }

        #
        # handles all outgoing requests
        #
        location /RestyHttpRequestProxy {
            internal;
            rewrite_by_lua_block {
                Resty:proxy()
            }
            proxy_buffering             on;
            proxy_buffers               256 4k;
            proxy_pass                  $uri$is_args$args;
            proxy_pass_request_headers  on;
            proxy_pass_request_body     on;
            #
            # timeout
            #
            proxy_connect_timeout   5s;
            proxy_send_timeout      10s;
            proxy_read_timeout      10s;
        }
    }
}
]=]

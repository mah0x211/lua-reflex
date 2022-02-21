-- handler get request for /:user/posts/*id
function handler.get(req, glob, data)
    -- set data for *id.html
    data.glob = glob
    data.user_posts_id = 'get'
end

-- handler any request for /:user/posts/*id
function handler.any(req, glob, data)
    data.glob = glob
    data.user_posts_id = 'any'
end

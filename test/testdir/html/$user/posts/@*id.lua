return {
    -- handler get request for /:user/posts/*id
    get = function(req, rsp)
        -- set data for *id.html
        rsp.body.params = req.params
        rsp.body.user_posts_id = 'get'
    end,

    -- handler any request for /:user/posts/*id
    any = function(req, rsp)
        rsp.body.params = req.params
        rsp.body.user_posts_id = 'any'
    end,
}

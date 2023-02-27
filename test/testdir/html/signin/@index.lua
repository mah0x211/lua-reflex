return {
    post = function(req, rsp)
        rsp.body.params = req.params
        rsp.body.signin = 'post'
    end,

    get = function(req, rsp)
        rsp.body.params = req.params
        rsp.body.signin = 'get'
    end,
}

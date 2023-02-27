return {
    get = function(req, rsp)
        rsp.body.params = req.params
        rsp.body.user = 'get'
    end,
}

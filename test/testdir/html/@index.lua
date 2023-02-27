return {
    get = function(req, rsp)
        rsp.body.params = req.params
        rsp.body['/'] = 'get'
        return 200
    end,
}

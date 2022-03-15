function handler.post(req, rsp)
    rsp.body.params = req.params
    rsp.body.signin = 'post'
end

function handler.get(req, rsp)
    rsp.body.params = req.params
    rsp.body.signin = 'get'
end

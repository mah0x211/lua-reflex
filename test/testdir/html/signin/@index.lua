function handler.post(req, glob, data)
    data.glob = glob
    data.signin = 'post'
end

function handler.get(req, glob, data)
    data.glob = glob
    data.signin = 'get'
end

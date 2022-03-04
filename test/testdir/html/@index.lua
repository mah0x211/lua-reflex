function handler.get(req, glob, data)
    data.glob = glob
    data['/'] = 'get'
    return 200
end


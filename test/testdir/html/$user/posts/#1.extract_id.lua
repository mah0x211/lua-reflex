-- extract id from *id parameter
function handler.all(req, rsp)
    rsp.body.extract_id = 'all'
end

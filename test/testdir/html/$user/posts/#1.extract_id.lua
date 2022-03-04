-- extract id from *id parameter
function handler.all(req, glob, data)
    data.extract_id = 'all'
end

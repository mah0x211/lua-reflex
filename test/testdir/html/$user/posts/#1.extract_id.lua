return {
    -- extract id from *id parameter
    all = function(req, rsp)
        rsp.body.extract_id = 'all'
    end,
}

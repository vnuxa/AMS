local module = {}

function module:Setup(discordia,client)
    local lib = {}

    function lib:Init(paths)
        for i,v in pairs(paths) do 
            require(v):Init(discordia,client)
        end
    end
    --Initialize libraries

    return lib
end

return module 
local module = {}

function module.Setup()
    local lib = {}

    function lib:Init(paths)
        for i,v in pairs(paths) do 
            require(v):Setup(discordia,client)
        end
    end
    --Initialize libraries

    return lib
end

return module 
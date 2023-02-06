local module = {}

function module:Init(discordia,client)
    local lib = {}

    function lib:GetUserFromStringID(guild,arg)
        return guild:getMember(arg)
    end
    

    
    return lib
end

return module
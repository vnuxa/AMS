local module = {}

function module:Init(discordia,client)
    local lib = {}

    function lib:GetUserFromString(guild,arg)
        local members = guild.members 
        for i,v in pairs(members) do 
            print("Members:", i,v)
        end
    end
    

    
    return lib
end

return module
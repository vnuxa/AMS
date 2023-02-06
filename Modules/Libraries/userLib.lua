local module = {}

function module:Init(discordia,client)
    local lib = {}

    function lib:GetUserFromString(guild,arg)
        local members = guild.members 
        for i,member in pairs(members) do 
            print("Members:", i,member.name)
        end
    end
    

    
    return lib
end

return module
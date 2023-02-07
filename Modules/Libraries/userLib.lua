local module = {}

function module:Init(discordia,client)
    local lib = {}

    function lib:GetUserFromStringID(guild,arg)
        return guild:getMember(arg)
    end
    --[[
        Discord perms:
        "Public",
    ]]
    function lib:CheckDiscordPermission(member,perm)
        local req = string.lower(perm)
        if req == "public" then return true end 
        if req == "hc" then return member:hasPermission("banMembers") end 
        if req == "mc" then return member:hasPermission("moveMembers") end
        print("No available permissions, got:",req)
        return nil
    end


    
    return lib
end

return module
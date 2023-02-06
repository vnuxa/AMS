local module = {}
local dcmd = require("discordia-commands")
function mysplit (inputstr, sep)
    if sep == nil then
       sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
       table.insert(t, str)
    end
    return t
 end

function module:Init(discordia,client)
    local intrType = discordia.enums.interactionType
    local slashClient = dia.Client():useApplicationCommands()
    
    --[[
    CLIENT:on("slashCommand", function(ia, cmd, args)

    end)
    ]]
    client:on("messageCreate", function(message)
        local args = mysplit(string.lower(message.content))
        for i,v in pairs(args) do print("Args:",i,v) end 
        if args[1] == "-warn" then 
            message:Reply("Command is still WIP (Also got user",tostring(args[2]),")")
        end
    end) 
end

return module
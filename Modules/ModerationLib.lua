local module = {}
--local dcmd = require("discordia-commands")
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
function wait(seconds)
  local start = os.time()
  repeat until os.time() > start + seconds
end
function module:Init(discordia,client)
   local libs = {}
   libs.user = require("./Libraries/userLib.lua"):Init(discordia,client)
   -- local intrType = discordia.enums.interactionType
    --local slashClient = dia.Client():useApplicationCommands()
    
    --[[
    CLIENT:on("slashCommand", function(ia, cmd, args)

    end)
    ]]
    client:on("messageCreate", function(message)
        if message.author == client.user then return end
        local args = mysplit(string.lower(message.content))
        if args[1] == "-warn" then 
            local member = libs.user:GetUserFromStringID(message.guild,args[2])
            local testString = "Found user"..   member.name
            message:reply(testString)
            
        end
    end) 
end

return module
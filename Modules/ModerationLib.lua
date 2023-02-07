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
   libs.embed = require("./Libraries/embedLib.lua"):Init(discordia,client)
   -- local intrType = discordia.enums.interactionType
    --local slashClient = dia.Client():useApplicationCommands()
    
    --[[
    CLIENT:on("slashCommand", function(ia, cmd, args)

    end)
    ]]
    libs.perms = {}
    function libs.perms:FullCheck(member,perm)
        
      local hasPerm = libs.user:CheckDiscordPermission(member,perm)  

    end
    function libs.perms:GetUser(message,argument)
        local id = argument:match('^<@!?(%d+)>$')
        -- Confirm the caller mentioned a valid user.
        local user
        if id then 
            user = client:getUser(id)
        else 
            user = client:getUser(argument)
        end
        if user then else message:reply("Member not found, no valid ID or mention.") return nil end 
        return user 
    end
    client:on("messageCreate", function(message)
        if message.author == client.user then return end
        local args = mysplit(string.lower(message.content))
        if args[1] == "-note" then 
            local author = message.guild:getMember(message.author.id)
            local member = message.mentionedUsers.first
            --Checking HC permissions
            if libs.user:CheckDiscordPermission(author,"hc") then else
                message:reply("You do not have high command permissions.") 
                return 
            end
            --Getting user
            local user = libs.perms:GetUser(message,args[2])
            if user then else return end

            local testString = "User: "..   user.name .. " Note: ".. args[3]
            local embedString = libs.embed:verifiedEmbed({
                authorName = "Note saved",
                description = "Your note of this user has been saved (he lies saving is WIP)"
                fields = {
                    {name = "Note information",value = "``"..args[3].."``"}
                }
            })
            message:reply(testString)
            
        end
    end) 
end

return module
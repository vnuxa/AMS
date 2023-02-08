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
   libs.trello = require("./Libraries/trelloLib.lua"):Init(discordia,client)
   libs.roblox = require("./Libraries/robloxLib.lua"):Init(discordia,client)
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
    local function getListId(listName)
        local boardId = "63e27f477168890c41e40eb1"
        local listId = nil
        local lists = libs.trello.Boards:GetListsOnBoard(boardId)
        for i,list in pairs(lists) do 
            if list.name == listName then listId = list.id break end
        end
        return listId
    end
    function libs.perms:GetUser(message,argument)
        local id = argument:match('^<@!?(%d+)>$')
        -- Confirm the caller mentioned a valid user.
        local user
        if id then 
            user = message.guild:getMember(id)
        else 
            user = message.guild:getMember(argument)
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
                message:reply{embeds = {
                    libs.embed:errorEmbed({
                        authorName = "Couldn't complete action",
                        description = "You are missing `HC` permissions. If you believe this is a mistake please contact the advisory team",
                    })
                }}
                return 
            end
            --Getting user
            local user = libs.perms:GetUser(message,args[2])
            if user then else 
                message:reply{embeds = {
                libs.embed:errorEmbed({
                    authorName = "Couldn't complete action",
                    description = "User `".. args[2] .."` has not been found"
                })
            }} return end
            local boardId = "63e27f477168890c41e40eb1"
            local listId = getListId("Notes")
            local card = libs.trello.Cards:GetCardOnList(listId,user.name)
            if card then 
                print("the description is ", card.desc)
                local updateCard = libs.trello.Cards:UpdateCard(card.id,
                {
                    Description = args[3]
                })
                print("The update status is",updateCard)
                message:reply{embeds = {
                    libs.embed:verifiedEmbed({
                        authorName = "Note saved",
                        description = "Your note of `".. user.name .."` has been saved",
                        fields = {
                            {name = "Note information",value = "``"..args[3].."``"},
                        },
                    })
                }}
            else 
                card = libs.trello.Cards:CreateCard(user.name,listId,{Description = args[3]})
                print(card)
                message:reply{embeds = {
                    libs.embed:verifiedEmbed({
                        authorName = "Note saved",
                        description = "Your note of `".. user.name .."` has been saved",
                        fields = {
                            {name = "Note information",value = "``"..args[3].."``"},
                        },
                    })
                }}
            end
            

        end
        if args[1] == "-suspend" then 
            local author = message.guild:getMember(message.author.id)
            local member = message.mentionedUsers.first
            --Checking HC permissions
            if libs.user:CheckDiscordPermission(author,"hc") then else
                message:reply{embeds = {
                    libs.embed:errorEmbed({
                        authorName = "Couldn't complete action",
                        description = "You are missing `HC` permissions. If you believe this is a mistake please contact the advisory team",
                    })
                }}
                return 
            end
            --Getting user
            local user = libs.perms:GetUser(message,args[2])
            if user then else 
                message:reply{embeds = {
                libs.embed:errorEmbed({
                    authorName = "Couldn't complete action",
                    description = "User `".. args[2] .."` has not been found"
                })
            }} return end
            local boardId = "63e27f477168890c41e40eb1"
            local listId = getListId("Suspensions")
            local card = libs.trello.Cards:GetCardOnList(listId,user.name)
            local epoch = args[3]
            if tonumber(epoch) ~= nil then else --Checking epoch time
                message:reply{embeds = {
                    libs.embed:errorEmbed({
                        authorName = "Couldn't complete action",
                        description = "Invalid Unix epoch time. If you do not know how to get epoch time [click here](https://www.epochconverter.com)."
                    })
                }}
                return end 
            end
            if card then 
                local updateCard = libs.trello.Cards:UpdateCard(card.id,
                {
                    Description = epoch
                })
                message:reply{embeds = {
                    libs.embed:verifiedEmbed({
                        authorName = "User successfully suspended",
                        description = "Your suspension of `".. user.name .."` has been saved",
                        fields = {
                            {name = "Suspension ends at: ",value = "<t:"..epoch..":f>"},
                        },
                    })
                }}
            else 
                
                card = libs.trello.Cards:CreateCard(user.name,listId,{Description = args[3]})
                print(card)
                message:reply{embeds = {
                    libs.embed:verifiedEmbed({
                        authorName = "Note saved",
                        description = "Your note of `".. user.name .."` has been saved",
                        fields = {
                            {name = "Note information",value = "``"..args[3].."``"},
                        },
                    })
                }}
            end

        end
        
        if args[1] == "-unsuspend" then 
            local author = message.guild:getMember(message.author.id)
            local member = message.mentionedUsers.first
            --Checking HC permissions
            if libs.user:CheckDiscordPermission(author,"hc") then else
                message:reply{embeds = {
                    libs.embed:errorEmbed({
                        authorName = "Couldn't complete action",
                        description = "You are missing `HC` permissions. If you believe this is a mistake please contact the advisory team",
                    })
                }}
                return 
            end
            --Getting user
            local user = libs.perms:GetUser(message,args[2])
            if user then else 
                message:reply{embeds = {
                libs.embed:errorEmbed({
                    authorName = "Couldn't complete action",
                    description = "User `".. args[2] .."` has not been found"
                })
            }} return end
            local boardId = "63e27f477168890c41e40eb1"
            local listId = getListId("Suspensions")
            local card = libs.trello.Cards:GetCardOnList(listId,user.name)
            if card then 
                local updateCard = libs.trello.Cards:UpdateCard(card.id,
                {
                    Description = epoch
                })
                message:reply{embeds = {
                    libs.embed:verifiedEmbed({
                        authorName = "User is now unsuspended",
                        description = "The suspension of `".. user.name .."` has been deleted",
                    })
                }}
            else 
                message:reply{embeds = {
                    libs.embed:errorEmbed({
                        authorName = "Couldn't complete action",
                        description = "User `".. args[2] .."` has not been found within active suspensions"
                    })
                }} 
            end

        end
        if args[1] == "-info" then 
            local author = message.guild:getMember(message.author.id)
            local member = message.mentionedUsers.first
            local boardId = "63e27f477168890c41e40eb1"

            local user = libs.perms:GetUser(message,args[2])
            if user then else 
                message:reply{embeds = {
                libs.embed:errorEmbed({
                    authorName = "Couldn't complete action",
                    description = "User `".. args[2] .."` has not been found"
                })
            }} return end
            local function getInfoFromList(ListName,data)
                local listId 
                local lists = libs.trello.Boards:GetListsOnBoard(boardId)
                for i,list in pairs(lists) do 
                    if list.name == ListName then listId = list.id break end
                end
                print(listId,ListName)
                if listId then else print("List",ListName,"not found") return end
                local card = libs.trello.Cards:GetCardOnList(listId,data)
                if card then 
                    return card.desc
                else 
                    --[[
                    libs.embed:errorEmbed({
                        authorName = "Couldn't complete action",
                        description = "User `".. user.name .."` has not been found within ".. ListName
                    }) ]]
                    return nil
                end
            end
            local notes = getInfoFromList("Notes",user.name)
            local suspensions = getInfoFromList("Suspensions",user.name)
            local robloxGroupId = libs.roblox:GetGroupId(message.guild.id)
            local userId = libs.roblox.User:GetIDFromName(user.nickname or user.name) 
            local thumbnail = libs.roblox.User:GetThumbnail(userId)
            local groupData = libs.roblox.User:GetGroupData(userId,robloxGroupId)
            local thumbnailUrl 
            if thumbnail then thumbnailUrl = thumbnail.data[1].imageUrl print(thumbnail.data[1].imageUrl) end
            if groupData and userId and robloxGroupId then else message:reply("Group data, user id and group id are possibly nil") end
            local embed = libs.embed:informationEmbed(
                {
                    title = "Information: ".. user.name,
                    description = "Group: ".. groupData.group.name,
                    fields = {
                        {
                            name = "Role", 
                            value = groupData.role.name.." ("..tostring(groupData.role.rank)..")", 
                            inline = true
                        },
                        {
                            name = "Suspended", 
                            value = suspensions or ":x:", --ADD A CHECK FOR SUSPENSIONS
                            inline = true
                        },
                        {
                            name = "Notes", 
                            value = notes or ":x:", --ADD A CHECK FOR SUSPENSIONS
                            inline = not (notes ~= nil)
                        }
                    },
                    thumbnail = {
                        url = thumbnailUrl
                    }
                }
            )
            message:reply{embeds = {
                embed
            }}
        
        end

    end) 
end

return module
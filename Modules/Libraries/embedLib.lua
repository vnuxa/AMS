local module = {}

function module:Init(discordia,client)
    local lib = {}
    --[[
        title = "Title",
        description = "Description",
        authorName = "author name",
        fields = {} --actual discord field btw
    ]]
    function lib:verifiedEmbed(changeTable)
        local embed = {
            title = changeTable["title"],
				description =changeTable["description"],
                timestamp = os.time(),
				author = {
					name = changeTable["authorName"],
					icon_url = "https://cdn.discordapp.com/attachments/769923541818671124/1071783887526699018/Checkmark.png"
				},
				fields = changeTable["fields"],
				footer = {
					text = "Autonomous Systems Manager",
                    icon_url = "https://cdn.discordapp.com/attachments/1066061560688156672/1066061689352638614/CRI_Main_Grey.png"
				},
				color = 0x000000 -- hex color code
        }
        return embed
    end

    
    return lib
end

return module
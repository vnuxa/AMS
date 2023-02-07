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
                title = changeTable["title"] or "",
				description =changeTable["description"] or "",
				author = {
					name = changeTable["authorName"],
					icon_url = "https://cdn.discordapp.com/attachments/769923541818671124/1071783887526699018/Checkmark.png"
				},
				fields = changeTable["fields"],
				footer = {
					text = "Autonomous Systems Manager • ".. os.date ("%A, %m %B %Y, %H:%M"),
                    icon_url = "https://cdn.discordapp.com/attachments/1066061560688156672/1066061689352638614/CRI_Main_Grey.png"
				},
				color = 0x6ce754, -- hex color code
        }
        return embed
    end
    function lib:errorEmbed(changeTable)
        local embed = {
                title = changeTable["title"] or "",
				description =changeTable["description"] or "",
				author = {
					name = changeTable["authorName"],
					icon_url = "http://msafe.i0.tf/1CyrM.png"
				},
				fields = changeTable["fields"],
				footer = {
					text = "Autonomous Systems Manager • ".. os.date ("%A, %m %B %Y, %H:%M"),
                    icon_url = "https://cdn.discordapp.com/attachments/1066061560688156672/1066061689352638614/CRI_Main_Grey.png"
				},
				color = 0xff5454, -- hex color code
        }
        return embed
    end
    
    return lib
end

return module
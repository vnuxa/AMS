local discordia = require("discordia")
require("discordia-interactions") -- Modifies Discordia and adds interactionCreate event
local client = discordia.Client()
local intrType = discordia.enums.interactionType


client:on("ready", function() -- bot is ready
	print("Logged in as " .. client.user.username)
end)

local handler = require("./Handler.lua")
handler.Setup(discordia,client):Init(
	{
		"./Modules/ModerationLib.lua",
	})
--[[
client:on("messageCreate", function(message)

	local content = message.content
	local author = message.author

	if content == "!embed" then
		message:reply {
			embed = {
				title = "Embed Title",
				description = "Here is my fancy description!",
				author = {
					name = author.username,
					icon_url = author.avatarURL
				},
				fields = { -- array of fields
					{
						name = "Field 1",
						value = "This is some information",
						inline = true
					},
					{
						name = "Field 2",
						value = "This is some more information",
						inline = false
					}
				},
				footer = {
					text = "Created with Discordia"
				},
				color = 0x000000 -- hex color code
			}
		}
	end
  if content == "!lua" then
    print(require("./Modules/test.lua"))
  end
end)
]]

client:run("Bot ".. os.getenv("TOKEN")) -- replace BOT_TOKEN with your bot token
--local keep_alive = require("./keepalive.py")
--keepalive()
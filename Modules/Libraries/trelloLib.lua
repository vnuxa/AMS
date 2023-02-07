local module = {}
local http = require('coro-http')
local json = require("json")

function module:Init(discordia,client)
    local lib = {}
    local Key = os.getenv("TrelloKey")
    local Token = os.getenv("TrelloToken")
    local TrelloAPIKey = Key
    local TrelloToken = Token
    
    local function urlRequest(method,url,body,headers,options)
        local response,body = http.request(method,url,headers,body,options)
        if res.code < 200 or res.code >= 300 then
            print("Request failed, reason: " .. res.reason); 
            return nil
        end
        return json.decode(body)
    end
    lib.Boards = {}
    
    function lib.Boards:GetLabelsOnBoard(BoardId)
        if BoardId then else print("Board ID not found") end
        return urlRequest("GET","https://api.trello.com/1/boards/" .. BoardId .. "/labels" .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken)
    end
    function lib.Boards:GetCardOnBoard(BoardId,CardName)
        if BoardId then else print("Board ID not found") end
        if CardName then else print("Card Name not found") end

        local CardID
        local Cards = lib.Boards:GetCardsOnBoard(BoardId)
        for _,Data in pairs(Cards) do
            if CardName == Data.name then
                CardID = Data.id
                local Response

                local Succ, Err = pcall(function()
                    Response = urlRequest("GET","https://api.trello.com/1/boards/" .. BoardId .. "/cards/" .. CardID .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken)
                end)
    
                if not Succ then
                    warn("[SERVER] BoardsAPI • [GetCardOnBoard] : ", Err)
                    return false
                else
                    return Response
                end
            else
                warn("[SERVER] BoardsAPI • [GetCardOnBoard] : Card Not Found.")
                return false
            end	
        end	
    end
    function lib.Boards:GetListsOnBoard(BoardId)
        if BoardId then else print("Board ID not found") end
        return urlRequest("GET","https://api.trello.com/1/boards/" .. BoardId .. "/lists?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken)
    end
    function lib.Boards:GetListID(BoardId,Name)
        if BoardId then else print("Board ID not found") end
        if Name then else print("Name not found") end
        local Lists = lib.Boards:GetListsOnBoard(BoardId)
        for _,DataList in pairs(Lists) do
            if Name == DataList.name then
                return DataList.id
            end
        end
        return false 
    end
    function lib.Boards:CreateListOnBoard(BoardId, Name)
        if BoardId then else print("Board ID not found") end
        if Name then else print("Name not found") end
        local body = urlRequest("POST","https://api.trello.com/1/boards/" .. BoardId .. "/lists" .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken, json.encode({name = Name, id = BoardId}))
        if body then return true end  
        return false 
    end
    --Boards API ends here
    --Start of cards API
    lib.Cards = {}
    function lib.Cards:GetCardsOnList(ListId)
        if ListId then else print("List ID not found") end
        return urlRequest("GET","https://api.trello.com/1/lists/" .. ListId .. "/cards?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken)
    end
    function lib.Cards:CreateListOnBoard(ListId, Name)
        if ListId then else print("List ID not found") end
        if Name then else print("Name not found") end
        local Cards = CardsAPI.GetCardsOnList(ListId)	

        for _,Data in pairs(Cards) do
            if Name == Data.name then
                return Data.id
            end
        end
        print("Card not found")
        return nil 
    end
    function lib.Cards:CreateCard(Name, ListId, BoardOptionalData)
        if ListId then else print("List ID not found") end
        if Name then else print("Name not found") end
        if not BoardOptionalData then
            BoardOptionalData = {}
        end

	    local DataToSend = {
            ["Description"] = BoardOptionalData.Description or nil ,
            ["idLabels"] = BoardOptionalData.idLabels or nil,
            ["AttachmentLink"] = BoardOptionalData.AttachmentLink or nil
        }
        local body = urlRequest("POST","https://api.trello.com/1/cards" .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken, json.encode({name = Name, desc = DataToSend.Description, idList = ListId, idLabels = DataToSend.idLabels,urlSource = DataToSend.AttachmentLink}))
        if body then return true end  
        return false 
    end
    function lib.Cards:UpdateCard(CardId, BoardOptionalData)
        if CardId then else print("Card ID not found") end
        if not BoardOptionalData then
            BoardOptionalData = {}
        end
        local DataToSend = {
            ["name"] = BoardOptionalData.Name or nil ,
            ["desc"] = BoardOptionalData.Description or nil,
            ["closed"] = BoardOptionalData.Closed or nil, 
            ["idLabels"] = BoardOptionalData.idLabels or nil, 
            ['idList'] = BoardOptionalData.idList
        }
        local body = urlRequest(
            "PUT", -- Method
            "https://api.trello.com/1/cards/" .. CardId .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken, --URL
            json.encode(DataToSend), --Body
            {["Content-Type"] = "application/json"}, --Headers
        )
        if body then return true end  
        return false 
    end
    function lib.Cards:DeleteCard(CardId)
        if CardId then else print("Card ID not found") end
        local body = urlRequest(
            "DELETE", -- Method
            "https://api.trello.com/1/cards/" .. CardId .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken, --URL
        )
    end
    function lib.Cards:GetAttachmentsOnCard(CardId)
        if CardId then else print("Card ID not found") end
        return urlRequest("GET","https://api.trello.com/1/cards/" .. CardId .. "/attachments?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken)
    end
    function lib.Cards:CreateAttachmentOnCard(CardId,AttachmentUrl)
        if CardId then else print("Card ID not found") end  
        local body = urlRequest(
            "POST", -- Method
            "https://api.trello.com/1/cards/" .. CardId .. "/attachments?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken, --URL
            json.encode({id = CardId, url = AttachmentUrl}), --Body
        )
        if body then return true end  
        return false 
    end
    function lib.Cards:DeleteAttachmentOnCard(CardId,Attachmentid)
        if CardId then else print("Card ID not found") end
        if Attachmentid then else print("Attachment ID not found") end
        local body = urlRequest(
            "DELETE", -- Method
            "https://api.trello.com/1/cards/" .. CardId .. "/attachments/" .. Attachmentid .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken, --URL
        )
    end
    return lib
end

return module
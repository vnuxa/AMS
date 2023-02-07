local module = {}
local http = require('coro-http')
local json = require("json")
function httpEncode(text) -- thanks to wiremod
    local ndata = string.gsub(text, "[^%w _~%.%-]", function(str)
        local nstr = string.format("%X", string.byte(str))
        return "%"..((string.len(nstr) == 1) and "0" or "")..nstr
    end)
    return (string.gsub(ndata, " ", "+"))
end

function httpDecode(s) -- https://www.lua.org/pil/20.3.html
    return s:gsub("+", " "):gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
end

function module:Init(discordia,client)
    --                                    WHEN DEBUGGING MAKE SURE THAT THE PROPRETIES TABLE IS SENT WITHIN THE URL!!!!
    local lib = {}
    local Key = os.getenv("TrelloKey")
    local Token = os.getenv("TrelloToken")
    local TrelloAPIKey = Key
    local TrelloToken = Token
    
    local function urlRequest(method,url,body,headers,options)
        local response,body = http.request(method,url,headers,body,options)
        if response.code < 200 or response.code >= 300 then
            print("Request failed, reason: " .. response.reason,body); 
            return nil
        end
        return json.decode(body)
    end
    lib.Boards = {}
    
    function lib.Boards:GetLabelsOnBoard(BoardId)
        if BoardId then else print("Board ID not found") end
        return urlRequest("GET","https://api.trello.com/1/boards/" .. BoardId .. "/labels" .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken)
    end
    function lib.Boards:GetCardsOnBoard(BoardId)
        if BoardId then else print("Board ID not found") end
        return urlRequest("GET","https://api.trello.com/1/boards/" .. BoardId .. "/cards" .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken)
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
                    print("[SERVER] BoardsAPI • [GetCardOnBoard] : ", Err)
                    return false
                else
                    return Response
                end
            else
                print("[SERVER] BoardsAPI • [GetCardOnBoard] : Card Not Found.")
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
    function lib.Cards:GetCardOnList(ListId,CardName)
        if CardName then else print("Card Name not found") end

        local CardID
        local Cards = lib.Cards:GetCardsOnList(ListId)
        for _,Data in pairs(Cards) do
            if CardName == Data.name then
                return Data
            end	
        end	
        print("Card not found")
        return false
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
            --BoardOptionalData = {}
        end

	    local DataToSend = {
            ["Description"] = BoardOptionalData.Description or nil ,
            ["idLabels"] = BoardOptionalData.idLabels or nil,
            ["AttachmentLink"] = BoardOptionalData.AttachmentLink or nil
        }
        local updateUrl = ""
        local num = 1
        for i,v in pairs({name = Name, desc = DataToSend.Description, idList = ListId, idLabels = DataToSend.idLabels,urlSource = DataToSend.AttachmentLink}) do 
            if num == 1 then 
                num = num + 1
                updateUrl = i.."=".. httpEncode(tostring(v))
            else 
                updateUrl = updateUrl .."&"..i.."=".. httpEncode(tostring(v))
            end
        end
        print("new update url",updateUrl)
        print("https://api.trello.com/1/cards" .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken,"&".. updateUrl)
        local body = urlRequest("POST",
        "https://api.trello.com/1/cards" .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken.."&".. updateUrl)
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
        for i,v in pairs(DataToSend) do 
            print("Data index:",i,"value",v)
        end
        local updateUrl = ""
        local num = 1
        for i,v in pairs(DataToSend) do 
            if num == 1 then 
                num = num + 1
                updateUrl = i.."=".. httpEncode(tostring(v))
            else 
                updateUrl = updateUrl .."&"..i.."=".. httpEncode(tostring(v))
            end
        end
        local body = urlRequest(
            "PUT", -- Method
            "https://api.trello.com/1/cards/" .. CardId .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken.."&".. updateUrl, --URL
            nil,
            {["Content-Type"] = "application/json"} --Headers
        )
        if body then return true end  
        return false 
    end
    function lib.Cards:DeleteCard(CardId)
        if CardId then else print("Card ID not found") end
        local body = urlRequest(
            "DELETE", -- Method
            "https://api.trello.com/1/cards/" .. CardId .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken --URL
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
            json.encode({id = CardId, url = AttachmentUrl}) --Body
        )
        if body then return true end  
        return false 
    end
    function lib.Cards:DeleteAttachmentOnCard(CardId,Attachmentid)
        if CardId then else print("Card ID not found") end
        if Attachmentid then else print("Attachment ID not found") end
        local body = urlRequest(
            "DELETE", -- Method
            "https://api.trello.com/1/cards/" .. CardId .. "/attachments/" .. Attachmentid .. "?key=" .. TrelloAPIKey .. "&token=" .. TrelloToken --URL
        )
    end
    return lib
end

return module
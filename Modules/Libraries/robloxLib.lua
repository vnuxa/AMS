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
    local lib = {}
    local cookie = os.getenv("TrelloToken")

    local function urlRequest(method,url,body,headers,options)
        local response,body = http.request(method,url,headers,body,options)
        if response.code < 200 or response.code >= 300 then
            print("Request failed, reason: " .. response.reason,body); 
            return nil
        end
        return json.decode(body)
    end

    function lib:GetGroupId(serverId)
        local serverIDToRobloxID = {
            ["917399907621535776"] = 13186189,
            ["923877545420677120"] = 14298973,
        }
        return serverIDToRobloxID[tostring(serverId)]
    end
    lib.User = {}
    function lib.User:GetIDFromName(Name) --https://api.roblox.com/users/get-by-username?username=
        if Name then else print("Put a valid name") return nil end
        return urlRequest("GET","https://api.roblox.com/users/get-by-username?username="..Name)
    end
    function lib.User:GetThumbnail(UserID)
        if UserID then else print("Put a valid ID") return nil end
        return urlRequest("GET","https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=".. tostring(UserID) .."&size=150x150&format=Png&isCircular=true")
    end
    function lib.User:GetGroupData(UserID,GroupId) 
        if UserID and GroupId then else print("Put a valid ID") return nil end
        local response = urlRequest("GET","https://groups.roblox.com/v1/users/".. UserID .."/groups/roles")
        if response then else print("User id invalid or is in no groups") end 
        for i,data in pairs(response) do 
            if data["group"]["id"] == GroupId then 
                return data
            end
        end
        return nil
    end
    lib.Group = {}
    
    function lib.Group:GetRoleFromGroup(UserID,GroupId)
        if UserID then else print("Put a valid ID") return nil end
        local data = lib.User:GetGroupData()
    end

    return lib
end

return module
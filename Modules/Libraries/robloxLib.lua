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
   
    function tableMerge(t1, t2)
        t1 = t1 or {}
        t2 = t2 or {}
        for k,v in pairs(t2) do
            if type(v) == "table" then
                if type(t1[k] or false) == "table" then
                    tableMerge(t1[k] or {}, t2[k] or {})
                else
                    t1[k] = v
                end
            else
                t1[k] = v
            end
        end
        return t1
    end
    local getCSRF
    local csrf = nil
    local request
    local presetHeaders = {
        ["Cookie"] = ".ROBLOSECURITY="..os.getenv("RobloxCookie"),
        --["x-csrf-token"] = csrf
    }
    request = function(method,url,body,header)
        local headers = tableMerge(header,presetHeaders)
        local bodyMerge = tableMerge(body,{["Content-Length"] = 0})
        
        method = string.upper(method)
        local response,jbody1 = http.request(method,url,headers,json.encode(bodyMerge))
        
        local statusCode = response.StatusCode
        if statusCode == 401 then
            error("A valid .ROBLOSECURITY cookie is required")
        elseif statusCode == 403 then
            local responseHeaders = response.Headers
            if responseHeaders["x-csrf-token"] then
                headers["x-csrf-token"] = responseHeaders["x-csrf-token"]
                return request(method, url, body,header)
            end
        end
        return {response = response,body = json.decode(jbody1)}
 
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
        return urlRequest("GET","https://api.roblox.com/users/get-by-username?username="..Name).Id
    end
    function lib.User:GetThumbnail(UserID)
        if UserID then else print("Put a valid ID") return nil end
        return urlRequest("GET","https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=".. tostring(UserID) .."&size=150x150&format=Png&isCircular=true")
    end
    function lib.User:GetGroupData(UserID,GroupId) 
        if UserID and GroupId then else print("Put a valid ID") return nil end
        local response = urlRequest("GET","https://groups.roblox.com/v1/users/".. UserID .."/groups/roles")
        if response then else print("User id invalid or is in no groups") end 
        for i,data in pairs(response.data) do 
            if data["group"]["id"] == GroupId then 
                return data
            end
        end
        return nil
    end
    
    lib.Group = {}
    
    function lib.Group:GetRoleFromGroup(GroupId,RoleName)
        if GroupId then else print("Put a valid ID") return nil end
        local rolesData = request("GET","https://groups.roblox.com/v1/groups/".. tostring(GroupId) .."/roles")
        local roles = rolesData.body.roles
        for i,v in pairs(roles) do 
            if tonumber(RoleName) ~= nil then 
                if tostring(v.rank) == RoleName then 
                    return v 
                end
            else
                print("Checking string",i,v)
                if string.lower(v.name) == string.lower(RoleName) then 
                    return v 
                end
            end
        end
        print("Role not found")
        return nil
    end
    
    function lib.Group:SetUserRank(UserID,GroupId,Rank)
        if GroupId and UserID then else print("Put a valid ID") return nil end
        if Rank then else print("Put a valid rank") return nil end
        local role = lib.Group:GetRoleFromGroup(GroupId,Rank)
        local data = request("PATCH","https://groups.roblox.com/v1/groups/".. tostring(GroupId) .."/users/".. tostring(UserID),{["roleId"] = role.id})
        print(data)
    end

    return lib
end

return module
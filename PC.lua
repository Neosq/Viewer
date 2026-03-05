-- ╔══════════════════════════════════════════════════════╗
-- ║    VCP VIEWER  —  Module 4: Player | Community       ║
-- ╚══════════════════════════════════════════════════════╝

local PCViewer = {}

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")

-- ─── Helpers ────────────────────────────────────────────
local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    return ok and res or nil
end

local function jsonDecode(str)
    local ok, res = pcall(HttpService.JSONDecode, HttpService, str)
    return ok and res or nil
end

local function formatDate(iso)
    if not iso then return "—" end
    local y,m,d = iso:match("(%d+)-(%d+)-(%d+)")
    if not y then return iso end
    local months = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return string.format("%s %s %s", d, months[tonumber(m)] or m, y)
end

-- ─── Input parsing ──────────────────────────────────────
--  Returns  type ("user" | "group"),  id (string)  or nil

local function parseInput(input)
    input = input:match("^%s*(.-)%s*$")

    -- roblox.com/users/123/profile
    local uid = input:match("roblox%.com/users/(%d+)")
    if uid then return "user", uid end

    -- roblox.com/groups/123
    local gid = input:match("roblox%.com/groups?/(%d+)")
    if gid then return "group", gid end

    -- bare number — ambiguous, caller chooses
    if input:match("^%d+$") then return "ambiguous", input end

    -- username (no slashes, no dots other than domain)
    if input:match("^[%w_]+$") then return "username", input end

    return nil, nil
end

-- ─── API endpoints ──────────────────────────────────────
local USER_BY_NAME   = "https://users.roblox.com/v1/usernames/users"
local USER_BY_ID     = "https://users.roblox.com/v1/users/%s"
local USER_THUMB     = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%s&size=150x150&format=Png"
local GROUP_BY_ID    = "https://groups.roblox.com/v1/groups/%s"
local GROUP_THUMB    = "https://thumbnails.roblox.com/v1/groups/icons?groupIds=%s&size=150x150&format=Png"

-- ─────────────────────────────────────────────────────────
--  PLAYER VIEWER
-- ─────────────────────────────────────────────────────────
function PCViewer.loadUser(GUI, userId)
    local T = GUI.Theme
    GUI.showLoading()

    task.spawn(function()
        local raw = httpGet(USER_BY_ID:format(userId))
        if not raw then GUI.showError("Failed to fetch user.") return end
        local data = jsonDecode(raw)
        if not data or data.errors then GUI.showError("User not found.") return end

        -- thumbnail
        local thumbUrl = ""
        local tRaw = httpGet(USER_THUMB:format(userId))
        if tRaw then
            local td = jsonDecode(tRaw)
            if td and td.data and td.data[1] then
                thumbUrl = td.data[1].imageUrl or ""
            end
        end

        GUI.clearContent()
        local cs = GUI.contentScroll

        -- Icon
        GUI.makeIcon(cs,
            UDim2.new(0,80,0,80),
            UDim2.new(0,12,0,12),
            thumbUrl ~= "" and thumbUrl or nil)

        local info = Instance.new("Frame")
        info.Size = UDim2.new(1,-108,0,400)
        info.Position = UDim2.new(0,104,0,8)
        info.BackgroundTransparency = 1
        info.Parent = cs

        local yOff = 0

        -- Name
        GUI.makeRow(info, yOff, "Name", data.name or "—", {
            {icon="⧉", text="Copy Roblox Link", callback=function()
                setclipboard("https://www.roblox.com/users/"..userId.."/profile")
            end},
            {icon="📊", text="Copy Rolimons Link", callback=function()
                setclipboard("https://www.rolimons.com/player/"..userId)
            end},
        })
        yOff = yOff + 26

        -- Display name
        if data.displayName and data.displayName ~= data.name then
            GUI.makeRow(info, yOff, "Display", data.displayName)
            yOff = yOff + 26
        end

        -- User ID
        GUI.makeRow(info, yOff, "User ID", tostring(userId))
        yOff = yOff + 26

        -- Created
        GUI.makeRow(info, yOff, "Created", formatDate(data.created))
        yOff = yOff + 26

        -- Banned
        if data.isBanned then
            GUI.makeRow(info, yOff, "Status", "⛔ Banned")
            yOff = yOff + 26
        end

        -- Verified badge
        if data.hasVerifiedBadge then
            GUI.makeRow(info, yOff, "Verified", "✓ Yes")
            yOff = yOff + 26
        end

        -- separator
        local div = Instance.new("Frame")
        div.Size = UDim2.new(1,-12,0,1)
        div.Position = UDim2.new(0,0,0,yOff+4)
        div.BackgroundColor3 = T.BORDER
        div.BorderSizePixel = 0
        div.Parent = info
        yOff = yOff + 14

        -- Description
        GUI.label(info, {
            Text = "Description",
            Size = UDim2.new(1,-12,0,18),
            Position = UDim2.new(0,0,0,yOff),
            TextColor3 = T.TEXT3,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
        })
        yOff = yOff + 20

        local descText = (data.description and data.description ~= "") and data.description or "(No bio)"
        local descBox = Instance.new("TextLabel")
        descBox.Size = UDim2.new(1,-12,0,70)
        descBox.Position = UDim2.new(0,0,0,yOff)
        descBox.BackgroundColor3 = T.SURFACE2
        descBox.BorderSizePixel = 0
        descBox.TextColor3 = T.TEXT2
        descBox.Font = Enum.Font.Gotham
        descBox.TextSize = 11
        descBox.TextXAlignment = Enum.TextXAlignment.Left
        descBox.TextYAlignment = Enum.TextYAlignment.Top
        descBox.TextWrapped = true
        descBox.Text = descText
        descBox.Parent = info
        GUI.corner(descBox, 6)
        local dp = Instance.new("UIPadding")
        dp.PaddingLeft   = UDim.new(0,6)
        dp.PaddingRight  = UDim.new(0,6)
        dp.PaddingTop    = UDim.new(0,5)
        dp.PaddingBottom = UDim.new(0,5)
        dp.Parent = descBox
        yOff = yOff + 78

        cs.CanvasSize = UDim2.new(0,0,0,yOff+16)
        GUI.setMainHeight(math.min(96 + yOff + 32, 560))
    end)
end

-- ─────────────────────────────────────────────────────────
--  COMMUNITY (GROUP) VIEWER
-- ─────────────────────────────────────────────────────────
function PCViewer.loadGroup(GUI, groupId)
    local T = GUI.Theme
    GUI.showLoading()

    task.spawn(function()
        local raw = httpGet(GROUP_BY_ID:format(groupId))
        if not raw then GUI.showError("Failed to fetch group.") return end
        local data = jsonDecode(raw)
        if not data or data.errors then GUI.showError("Group not found.") return end

        -- thumbnail
        local thumbUrl = ""
        local tRaw = httpGet(GROUP_THUMB:format(groupId))
        if tRaw then
            local td = jsonDecode(tRaw)
            if td and td.data and td.data[1] then
                thumbUrl = td.data[1].imageUrl or ""
            end
        end

        GUI.clearContent()
        local cs = GUI.contentScroll

        GUI.makeIcon(cs,
            UDim2.new(0,80,0,80),
            UDim2.new(0,12,0,12),
            thumbUrl ~= "" and thumbUrl or nil)

        local info = Instance.new("Frame")
        info.Size = UDim2.new(1,-108,0,500)
        info.Position = UDim2.new(0,104,0,8)
        info.BackgroundTransparency = 1
        info.Parent = cs

        local yOff = 0

        -- Name
        GUI.makeRow(info, yOff, "Name", data.name or "—", {
            {icon="⧉", text="Copy Roblox Link", callback=function()
                setclipboard("https://www.roblox.com/groups/"..groupId)
            end},
            {icon="📊", text="Copy Rolimons Link", callback=function()
                setclipboard("https://www.rolimons.com/group/"..groupId)
            end},
        })
        yOff = yOff + 26

        -- Group ID
        GUI.makeRow(info, yOff, "Group ID", tostring(groupId))
        yOff = yOff + 26

        -- Owner
        local ownerName = data.owner and data.owner.username or "Nobody"
        local ownerId   = data.owner and data.owner.userId
        GUI.makeRow(info, yOff, "Owner", ownerName, {
            {icon="⧉", text="Copy Roblox Link", callback=function()
                if ownerId then
                    setclipboard("https://www.roblox.com/users/"..tostring(ownerId).."/profile")
                end
            end},
            {icon="→", text="View Profile", callback=function()
                if GUI.onViewCreator and ownerId then
                    GUI.onViewCreator("User", ownerId)
                end
            end},
        })
        yOff = yOff + 26

        -- Member count
        if data.memberCount then
            GUI.makeRow(info, yOff, "Members", tostring(data.memberCount))
            yOff = yOff + 26
        end

        -- Verified badge
        if data.hasVerifiedBadge then
            GUI.makeRow(info, yOff, "Verified", "✓ Yes")
            yOff = yOff + 26
        end

        -- separator
        local div = Instance.new("Frame")
        div.Size = UDim2.new(1,-12,0,1)
        div.Position = UDim2.new(0,0,0,yOff+4)
        div.BackgroundColor3 = T.BORDER
        div.BorderSizePixel = 0
        div.Parent = info
        yOff = yOff + 14

        -- Description
        GUI.label(info, {
            Text = "Description",
            Size = UDim2.new(1,-12,0,18),
            Position = UDim2.new(0,0,0,yOff),
            TextColor3 = T.TEXT3,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
        })
        yOff = yOff + 20

        local descText = (data.description and data.description ~= "") and data.description or "(No description)"
        local descBox = Instance.new("TextLabel")
        descBox.Size = UDim2.new(1,-12,0,90)
        descBox.Position = UDim2.new(0,0,0,yOff)
        descBox.BackgroundColor3 = T.SURFACE2
        descBox.BorderSizePixel = 0
        descBox.TextColor3 = T.TEXT2
        descBox.Font = Enum.Font.Gotham
        descBox.TextSize = 11
        descBox.TextXAlignment = Enum.TextXAlignment.Left
        descBox.TextYAlignment = Enum.TextYAlignment.Top
        descBox.TextWrapped = true
        descBox.Text = descText
        descBox.Parent = info
        GUI.corner(descBox, 6)
        local dp = Instance.new("UIPadding")
        dp.PaddingLeft   = UDim.new(0,6)
        dp.PaddingRight  = UDim.new(0,6)
        dp.PaddingTop    = UDim.new(0,5)
        dp.PaddingBottom = UDim.new(0,5)
        dp.Parent = descBox
        yOff = yOff + 98

        cs.CanvasSize = UDim2.new(0,0,0,yOff+16)
        GUI.setMainHeight(math.min(96 + yOff + 32, 580))
    end)
end

-- ─────────────────────────────────────────────────────────
--  RESOLVE INPUT → load correct viewer
-- ─────────────────────────────────────────────────────────
function PCViewer.resolve(GUI, input)
    local kind, id = parseInput(input)
    if not kind then
        GUI.showError("Invalid input. Use a Roblox URL, username, or numeric ID.")
        return
    end

    if kind == "user" then
        PCViewer.loadUser(GUI, id)

    elseif kind == "group" then
        PCViewer.loadGroup(GUI, id)

    elseif kind == "username" then
        -- POST to username lookup
        GUI.showLoading()
        task.spawn(function()
            local body = HttpService:JSONEncode({usernames={id}, excludeBannedUsers=false})
            local ok, res = pcall(function()
                return game:HttpGet(USER_BY_NAME, body)
            end)
            -- Note: HttpGet doesn't support POST; in executor contexts use syn.request or http.request
            -- Fallback: try searching via different endpoint
            local searchRaw = httpGet("https://users.roblox.com/v1/users/search?keyword="..id.."&limit=1")
            if searchRaw then
                local sd = jsonDecode(searchRaw)
                if sd and sd.data and #sd.data > 0 then
                    PCViewer.loadUser(GUI, tostring(sd.data[1].id))
                    return
                end
            end
            GUI.showError("Username '"..id.."' not found.")
        end)

    elseif kind == "ambiguous" then
        -- Try user first, then group
        GUI.showLoading()
        task.spawn(function()
            local uRaw = httpGet(USER_BY_ID:format(id))
            if uRaw then
                local ud = jsonDecode(uRaw)
                if ud and not ud.errors and ud.name then
                    PCViewer.loadUser(GUI, id)
                    return
                end
            end
            local gRaw = httpGet(GROUP_BY_ID:format(id))
            if gRaw then
                local gd = jsonDecode(gRaw)
                if gd and not gd.errors and gd.name then
                    PCViewer.loadGroup(GUI, id)
                    return
                end
            end
            GUI.showError("ID "..id.." not found as user or group.")
        end)
    end
end

-- ─────────────────────────────────────────────────────────
--  INIT
-- ─────────────────────────────────────────────────────────
function PCViewer.init(GUI)
    GUI.searchBox.PlaceholderText = "Profile URL, username, or ID..."

    GUI.goBtn.MouseButton1Click:Connect(function()
        local input = GUI.searchBox.Text:match("^%s*(.-)%s*$")
        if input == "" then return end
        PCViewer.resolve(GUI, input)
    end)
end

-- Export resolve so other modules can call it
PCViewer.parseInput  = parseInput

return PCViewer

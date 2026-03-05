-- ╔══════════════════════════════════════════════════════╗
-- ║          VCP VIEWER  —  Module 3: Game Viewer        ║
-- ╚══════════════════════════════════════════════════════╝

local GameViewer = {}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player  = Players.LocalPlayer

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

local function formatDateTime(iso)
    if not iso then return "—" end
    local y,m,d,h,min,s = iso:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    if not y then return formatDate(iso) end
    local months = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return string.format("%s %s %s  %s:%s:%s", d, months[tonumber(m)] or m, y, h, min, s)
end

local function extractPlaceId(input)
    -- roblox.com/games/12345/...
    local id = input:match("games/(%d+)")
    if id then return id end
    if input:match("^%d+$") then return input end
    return nil
end

-- ─── API ────────────────────────────────────────────────
local GAMES_API       = "https://games.roblox.com/v1/games?universeIds=%s"
local UNIVERSE_API    = "https://apis.roblox.com/universes/v1/places/%s/universe"
local THUMB_API       = "https://thumbnails.roblox.com/v1/games/icons?universeIds=%s&size=150x150&format=Png"
local SUBPLACES_API   = "https://games.roblox.com/v1/games/%s/subplaces?sortOrder=Asc&limit=50"
local USER_API        = "https://users.roblox.com/v1/users/%s"
local GROUP_API       = "https://groups.roblox.com/v1/groups/%s"

-- ─────────────────────────────────────────────────────────
--  TELEPORT HELPERS
-- ─────────────────────────────────────────────────────────
local function teleportTo(placeId)
    pcall(function()
        TeleportService:Teleport(tonumber(placeId), player)
    end)
end

local function copyTeleportScript(placeId)
    setclipboard(string.format(
        'game:GetService("TeleportService"):Teleport(%s, game.Players.LocalPlayer)',
        placeId
    ))
end

-- ─────────────────────────────────────────────────────────
--  SUBPLACES SIDE GUI
-- ─────────────────────────────────────────────────────────
local function openSubPlaces(GUI, universeId, currentPlaceId)
    local raw = httpGet(SUBPLACES_API:format(universeId))
    local T   = GUI.Theme
    if not raw then
        GUI.showError("Failed to load sub places.")
        return
    end
    local data = jsonDecode(raw)
    if not data or not data.data then
        GUI.showError("No sub places data.")
        return
    end

    local places = data.data

    GUI.openSideGui("Sub Places", function(scroll)
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0,4)
        layout.Parent = scroll
        local pad = Instance.new("UIPadding")
        pad.PaddingTop  = UDim.new(0,6)
        pad.PaddingLeft = UDim.new(0,6)
        pad.PaddingRight = UDim.new(0,6)
        pad.Parent = scroll

        local totalH = 0

        for _, place in ipairs(places) do
            local placeId = tostring(place.id or place.placeId or "")
            local name    = place.name or ("Place " .. placeId)
            local isHere  = (placeId == tostring(currentPlaceId))

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,-12,0,52)
            row.BackgroundColor3 = T.SURFACE2
            row.BorderSizePixel = 0
            row.Parent = scroll
            GUI.corner(row, 8)

            local nameL = GUI.label(row, {
                Text = name .. (isHere and "  ✓" or ""),
                Size = UDim2.new(1,-12,0,22),
                Position = UDim2.new(0,8,0,4),
                TextColor3 = isHere and T.SUCCESS or T.TEXT,
                TextSize = 12,
                Font = Enum.Font.GothamMedium,
                TextTruncate = Enum.TextTruncate.AtEnd,
            })

            local idL = GUI.label(row, {
                Text = "ID: " .. placeId,
                Size = UDim2.new(1,-12,0,16),
                Position = UDim2.new(0,8,0,26),
                TextColor3 = T.TEXT3,
                TextSize = 10,
            })

            -- mini menu button
            local menuBtn = GUI.btn(row, {
                Text = "•••",
                Size = UDim2.new(0,32,0,20),
                Position = UDim2.new(1,-38,0.5,-10),
                BackgroundColor3 = T.SURFACE,
                TextColor3 = T.TEXT2,
                TextSize = 12,
                ZIndex = 5,
            })
            GUI.addButtonFX(menuBtn, T.SURFACE, T.BORDER, T.BORDER2)
            menuBtn.MouseButton1Click:Connect(function()
                local items = {
                    {icon="🚀", text="Teleport", callback=function()
                        teleportTo(placeId)
                    end},
                    {icon="⧉", text="Copy Script", callback=function()
                        copyTeleportScript(placeId)
                    end},
                }
                local mg = GUI.createMiniGui(items, menuBtn.AbsolutePosition)
                mg.Visible = true
            end)

            totalH = totalH + 56
        end

        scroll.CanvasSize = UDim2.new(0,0,0,totalH + 12)
    end)
end

-- ─────────────────────────────────────────────────────────
--  MAIN LOAD
-- ─────────────────────────────────────────────────────────
function GameViewer.load(GUI, placeId, isCurrentPlace)
    local T = GUI.Theme
    GUI.showLoading()

    task.spawn(function()
        -- get universe id from place id
        local uniRaw = httpGet(UNIVERSE_API:format(placeId))
        local universeId
        if uniRaw then
            local ud = jsonDecode(uniRaw)
            universeId = ud and tostring(ud.universeId)
        end

        if not universeId then
            -- fallback: try place id as universe id
            universeId = placeId
        end

        -- fetch game data
        local raw = httpGet(GAMES_API:format(universeId))
        if not raw then
            GUI.showError("Failed to fetch game data.")
            return
        end
        local data = jsonDecode(raw)
        if not data or not data.data or #data.data == 0 then
            GUI.showError("Game not found.")
            return
        end
        local gd = data.data[1]

        -- thumbnail
        local thumbUrl = ""
        local tRaw = httpGet(THUMB_API:format(universeId))
        if tRaw then
            local td = jsonDecode(tRaw)
            if td and td.data and td.data[1] then
                thumbUrl = td.data[1].imageUrl or ""
            end
        end

        -- creator info
        local creatorName = gd.creator and gd.creator.name or "Unknown"
        local creatorId   = gd.creator and gd.creator.id
        local creatorType = gd.creator and gd.creator.type  -- "User" or "Group"

        -- Build UI
        GUI.clearContent()
        local cs = GUI.contentScroll

        local iconFrame, iconImg = GUI.makeIcon(cs,
            UDim2.new(0, 90, 0, 90),
            UDim2.new(0, 12, 0, 12),
            thumbUrl ~= "" and thumbUrl or nil)

        local info = Instance.new("Frame")
        info.Size = UDim2.new(1,-116,0,600)
        info.Position = UDim2.new(0,110,0,8)
        info.BackgroundTransparency = 1
        info.Parent = cs

        local yOff = 0

        -- Name
        GUI.makeRow(info, yOff, "Name", gd.name or "—", {
            {icon="⧉", text="Copy Roblox Link", callback=function()
                setclipboard("https://www.roblox.com/games/"..placeId)
            end},
            {icon="📊", text="Copy Rolimons Link", callback=function()
                setclipboard("https://www.rolimons.com/game/"..universeId)
            end},
        })
        yOff = yOff + 26

        -- Created by
        GUI.makeRow(info, yOff, "Created by", creatorName, {
            {icon="⧉", text="Copy Roblox Link", callback=function()
                if creatorType == "Group" then
                    setclipboard("https://www.roblox.com/groups/"..tostring(creatorId or ""))
                else
                    setclipboard("https://www.roblox.com/users/"..tostring(creatorId or "").."/profile")
                end
            end},
            {icon="📊", text="Copy Rolimons Link", callback=function()
                if creatorType == "Group" then
                    setclipboard("https://www.rolimons.com/group/"..tostring(creatorId or ""))
                else
                    setclipboard("https://www.rolimons.com/player/"..tostring(creatorId or ""))
                end
            end},
            {icon="→", text="View Profile", callback=function()
                if GUI.onViewCreator then
                    GUI.onViewCreator(creatorType, creatorId)
                end
            end},
        })
        yOff = yOff + 26

        -- Created at
        GUI.makeRow(info, yOff, "Created at", formatDate(gd.created))
        yOff = yOff + 26

        -- Updated at (live)
        local _, uaVal = GUI.makeRow(info, yOff, "Updated at", "—")
        yOff = yOff + 26
        task.spawn(function()
            while uaVal and uaVal.Parent do
                local fr = httpGet(GAMES_API:format(universeId))
                if fr then
                    local fd = jsonDecode(fr)
                    if fd and fd.data and fd.data[1] then
                        uaVal.Text = formatDateTime(fd.data[1].updated)
                    end
                end
                task.wait(30)
            end
        end)

        -- Stats
        if gd.playing then
            GUI.makeRow(info, yOff, "Playing", tostring(gd.playing))
            yOff = yOff + 26
        end
        if gd.visits then
            GUI.makeRow(info, yOff, "Visits", string.format("%s", tostring(gd.visits)))
            yOff = yOff + 26
        end
        if gd.maxPlayers then
            GUI.makeRow(info, yOff, "Max Players", tostring(gd.maxPlayers))
            yOff = yOff + 26
        end

        -- separator
        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(1,-12,0,1)
        divider.Position = UDim2.new(0,0,0,yOff+4)
        divider.BackgroundColor3 = T.BORDER
        divider.BorderSizePixel = 0
        divider.Parent = info
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

        local descBox = Instance.new("TextLabel")
        descBox.Size = UDim2.new(1,-12,0,80)
        descBox.Position = UDim2.new(0,0,0,yOff)
        descBox.BackgroundColor3 = T.SURFACE2
        descBox.BorderSizePixel = 0
        descBox.TextColor3 = T.TEXT2
        descBox.Font = Enum.Font.Gotham
        descBox.TextSize = 11
        descBox.TextXAlignment = Enum.TextXAlignment.Left
        descBox.TextYAlignment = Enum.TextYAlignment.Top
        descBox.TextWrapped = true
        descBox.Text = (gd.description and gd.description ~= "") and gd.description or "(No description)"
        descBox.Parent = info
        GUI.corner(descBox, 6)
        local dp = Instance.new("UIPadding")
        dp.PaddingLeft   = UDim.new(0,6)
        dp.PaddingRight  = UDim.new(0,6)
        dp.PaddingTop    = UDim.new(0,5)
        dp.PaddingBottom = UDim.new(0,5)
        dp.Parent = descBox
        yOff = yOff + 88

        -- ── Blue ">" action button ───────────────────────
        local currentId = game.PlaceId
        local canSeeSubPlaces = (tostring(currentId) == tostring(placeId))

        local actionBtn = Instance.new("TextButton")
        actionBtn.Size = UDim2.new(0,28,0,28)
        actionBtn.Position = UDim2.new(0, 0, 0, yOff + 4)
        actionBtn.BackgroundColor3 = T.BTN_BLUE
        actionBtn.TextColor3 = Color3.fromRGB(255,255,255)
        actionBtn.Text = "›"
        actionBtn.Font = Enum.Font.GothamBold
        actionBtn.TextSize = 20
        actionBtn.BorderSizePixel = 0
        actionBtn.Parent = info
        GUI.corner(actionBtn, 6)
        GUI.addButtonFX(actionBtn, T.BTN_BLUE, T.BTN_BLUE_H, Color3.fromRGB(0,100,180))
        yOff = yOff + 40

        actionBtn.MouseButton1Click:Connect(function()
            local items = {
                {icon="🚀", text="Teleport", callback=function()
                    teleportTo(placeId)
                end},
                {icon="⧉", text="Copy Teleport Script", callback=function()
                    copyTeleportScript(placeId)
                end},
            }
            if canSeeSubPlaces then
                table.insert(items, {
                    icon="📂",
                    text="Sub Places",
                    callback=function()
                        openSubPlaces(GUI, universeId, currentId)
                    end,
                })
            end
            local mg = GUI.createMiniGui(items, actionBtn.AbsolutePosition)
            mg.Visible = true
        end)

        cs.CanvasSize = UDim2.new(0,0,0,yOff+16)
        GUI.setMainHeight(math.min(96 + yOff + 32, 620))
    end)
end

-- ─────────────────────────────────────────────────────────
--  INIT
-- ─────────────────────────────────────────────────────────
function GameViewer.init(GUI)
    GUI.searchBox.PlaceholderText = "Game URL or Place ID..."

    -- VCP button fills in current place
    GUI.vcpBtn.MouseButton1Click:Connect(function()
        local id = tostring(game.PlaceId)
        GUI.searchBox.Text = id
        GameViewer.load(GUI, id, true)
    end)

    GUI.goBtn.MouseButton1Click:Connect(function()
        local input = GUI.searchBox.Text:match("^%s*(.-)%s*$")
        if input == "" then return end
        local id = extractPlaceId(input)
        if not id then
            GUI.showError("Invalid input. Use a game URL or Place ID.")
            return
        end
        GameViewer.load(GUI, id, false)
    end)
end

local function extractPlaceId(input)
    local id = input:match("games/(%d+)")
    if id then return id end
    if input:match("^%d+$") then return input end
    return nil
end

-- patch module-level reference
GameViewer._extractPlaceId = extractPlaceId

return GameViewer

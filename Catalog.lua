-- ╔══════════════════════════════════════════════════════╗
-- ║         VCP VIEWER  —  Module 2: Catalog Viewer      ║
-- ╚══════════════════════════════════════════════════════╝

local CatalogViewer = {}

-- ─── Services ───────────────────────────────────────────
local HttpService    = game:GetService("HttpService")
local TweenService   = game:GetService("TweenService")
local Players        = game:GetService("Players")
local player         = Players.LocalPlayer

-- ─── Helpers ────────────────────────────────────────────
local function httpGet(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if ok then return res end
    return nil
end

local function jsonDecode(str)
    local ok, res = pcall(HttpService.JSONDecode, HttpService, str)
    if ok then return res end
    return nil
end

local function formatDate(iso)
    if not iso then return "—" end
    -- ISO 8601: 2023-05-14T10:30:00Z
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

local function extractId(input)
    -- catalog URL: roblox.com/catalog/12345678/...
    local id = input:match("catalog/(%d+)")
    if id then return id end
    -- bare number
    if input:match("^%d+$") then return input end
    return nil
end

-- ─── Roblox API endpoints ───────────────────────────────
local ECONOMY_API  = "https://economy.roblox.com/v2/assets/%s/details"
local THUMB_API    = "https://thumbnails.roblox.com/v1/assets?assetIds=%s&size=150x150&format=Png"
local USER_API     = "https://users.roblox.com/v1/users/%s"
local GROUP_API    = "https://groups.roblox.com/v1/groups/%s"

-- ─────────────────────────────────────────────────────────
--  MAIN BUILD FUNCTION
-- ─────────────────────────────────────────────────────────
function CatalogViewer.load(GUI, assetId)
    local T = GUI.Theme

    GUI.showLoading()

    task.spawn(function()
        -- ── Fetch asset details ──────────────────────────
        local raw = httpGet(ECONOMY_API:format(assetId))
        if not raw then
            GUI.showError("Failed to fetch asset. Check HttpEnabled.")
            return
        end
        local data = jsonDecode(raw)
        if not data or data.errors then
            GUI.showError("Asset not found or API error.")
            return
        end

        -- ── Fetch thumbnail ──────────────────────────────
        local thumbUrl = ""
        local thumbRaw = httpGet(THUMB_API:format(assetId))
        if thumbRaw then
            local td = jsonDecode(thumbRaw)
            if td and td.data and td.data[1] then
                thumbUrl = td.data[1].imageUrl or ""
            end
        end

        -- ── Fetch creator info ───────────────────────────
        local creatorName  = data.Creator and data.Creator.Name or "Unknown"
        local creatorId    = data.Creator and data.Creator.CreatorTargetId
        local creatorType  = data.Creator and data.Creator.CreatorType  -- "User" or "Group"

        -- ── Build UI ─────────────────────────────────────
        GUI.clearContent()

        local CONTENT_H = 320
        GUI.setMainHeight(96 + CONTENT_H + 16)

        local cs = GUI.contentScroll
        cs.CanvasSize = UDim2.new(0, 0, 0, CONTENT_H)

        -- Icon
        local iconFrame, iconImg = GUI.makeIcon(cs,
            UDim2.new(0, 90, 0, 90),
            UDim2.new(0, 12, 0, 12),
            thumbUrl ~= "" and thumbUrl or nil)

        -- Right side container
        local info = Instance.new("Frame")
        info.Size = UDim2.new(1, -116, 0, CONTENT_H - 10)
        info.Position = UDim2.new(0, 110, 0, 8)
        info.BackgroundTransparency = 1
        info.Parent = cs

        local yOff = 0

        -- Name row
        local _, nameVal, nameCopy = GUI.makeRow(info, yOff, "Name", data.Name or "—", {
            {icon="⧉", text="Copy Roblox Link", callback=function()
                setclipboard("https://www.roblox.com/catalog/" .. assetId)
            end},
            {icon="📊", text="Copy Rolimons Link", callback=function()
                setclipboard("https://www.rolimons.com/item/" .. assetId)
            end},
        })
        yOff = yOff + 26

        -- Created by row
        local function openCreatorViewer()
            -- fires back into the main search to view that creator
            if GUI.onViewCreator then
                GUI.onViewCreator(creatorType, creatorId)
            end
        end

        GUI.makeRow(info, yOff, "Created by", creatorName, {
            {icon="⧉", text="Copy Roblox Link", callback=function()
                if creatorType == "Group" then
                    setclipboard("https://www.roblox.com/groups/" .. (creatorId or ""))
                else
                    setclipboard("https://www.roblox.com/users/" .. (creatorId or "") .. "/profile")
                end
            end},
            {icon="📊", text="Copy Rolimons Link", callback=function()
                if creatorType == "Group" then
                    setclipboard("https://www.rolimons.com/group/" .. (creatorId or ""))
                else
                    setclipboard("https://www.rolimons.com/player/" .. (creatorId or ""))
                end
            end},
            {icon="→", text="View Profile", callback=openCreatorViewer},
        })
        yOff = yOff + 26

        -- Created at
        local createdAt = data.Created or ""
        local _, caVal = GUI.makeRow(info, yOff, "Created at", formatDate(createdAt))
        yOff = yOff + 26

        -- Updated at (auto-refreshing)
        local _, uaVal = GUI.makeRow(info, yOff, "Updated at", "—")
        yOff = yOff + 26

        -- refresh updated label live
        task.spawn(function()
            while uaVal and uaVal.Parent do
                local fresh = httpGet(ECONOMY_API:format(assetId))
                if fresh then
                    local fd = jsonDecode(fresh)
                    if fd and fd.Updated then
                        uaVal.Text = formatDateTime(fd.Updated)
                    end
                end
                task.wait(30)
            end
        end)

        -- Price / Sales
        if data.PriceInRobux then
            GUI.makeRow(info, yOff, "Price", "R$ " .. tostring(data.PriceInRobux))
            yOff = yOff + 26
        end
        if data.Sales then
            GUI.makeRow(info, yOff, "Sales", tostring(data.Sales))
            yOff = yOff + 26
        end
        if data.Remaining ~= nil then
            GUI.makeRow(info, yOff, "Remaining", data.Remaining == nil and "∞" or tostring(data.Remaining))
            yOff = yOff + 26
        end

        -- separator
        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(1, -12, 0, 1)
        divider.Position = UDim2.new(0, 0, 0, yOff + 4)
        divider.BackgroundColor3 = T.BORDER
        divider.BorderSizePixel = 0
        divider.Parent = info
        yOff = yOff + 14

        -- Description (scrollable label)
        local descTitle = GUI.label(info, {
            Text = "Description",
            Size = UDim2.new(1, -12, 0, 18),
            Position = UDim2.new(0, 0, 0, yOff),
            TextColor3 = T.TEXT3,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
        })
        yOff = yOff + 20

        local descBox = Instance.new("TextLabel")
        descBox.Size = UDim2.new(1, -12, 0, 80)
        descBox.Position = UDim2.new(0, 0, 0, yOff)
        descBox.BackgroundColor3 = T.SURFACE2
        descBox.BorderSizePixel = 0
        descBox.TextColor3 = T.TEXT2
        descBox.Font = Enum.Font.Gotham
        descBox.TextSize = 11
        descBox.TextXAlignment = Enum.TextXAlignment.Left
        descBox.TextYAlignment = Enum.TextYAlignment.Top
        descBox.TextWrapped = true
        descBox.Text = (data.Description and data.Description ~= "") and data.Description or "(No description)"
        descBox.Parent = info
        GUI.corner(descBox, 6)

        local descPad = Instance.new("UIPadding")
        descPad.PaddingLeft   = UDim.new(0,6)
        descPad.PaddingRight  = UDim.new(0,6)
        descPad.PaddingTop    = UDim.new(0,5)
        descPad.PaddingBottom = UDim.new(0,5)
        descPad.Parent = descBox

        yOff = yOff + 88

        -- resize canvas
        cs.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)
        GUI.setMainHeight(math.min(96 + yOff + 36, 600))
    end)
end

-- ─────────────────────────────────────────────────────────
--  ENTRY POINT  (called by main init when mode = Catalog)
-- ─────────────────────────────────────────────────────────
function CatalogViewer.init(GUI)
    GUI.searchBox.PlaceholderText = "Asset URL or ID..."
    GUI.goBtn.MouseButton1Click:Connect(function()
        local input = GUI.searchBox.Text:match("^%s*(.-)%s*$")
        if input == "" then return end
        local id = extractId(input)
        if not id then
            GUI.showError("Invalid input. Use a catalog URL or asset ID.")
            return
        end
        CatalogViewer.load(GUI, id)
    end)
end

return CatalogViewer

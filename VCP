-- ╔══════════════════════════════════════════════════════════════════╗
-- ║                    VCP VIEWER  v1.0                              ║
-- ║            Combined single-file executor bundle                  ║
-- ║                                                                  ║
-- ║  Modules included:                                               ║
-- ║   [1] GUI Core        — main frame, mini gui, side gui          ║
-- ║   [2] Catalog Viewer  — asset info, live Updated at             ║
-- ║   [3] Game Viewer     — game info, sub places, teleport         ║
-- ║   [4] PC Viewer       — player & community (group) info         ║
-- ╚══════════════════════════════════════════════════════════════════╝

-- ════════════════════════════════════════════════════════════════════
--  [1]  GUI CORE
-- ════════════════════════════════════════════════════════════════════
local GUI = (function()
local GUI = {}

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local player           = Players.LocalPlayer

GUI.Theme = {
    BG         = Color3.fromRGB(10,  10,  10),
    SURFACE    = Color3.fromRGB(18,  18,  18),
    SURFACE2   = Color3.fromRGB(26,  26,  26),
    BORDER     = Color3.fromRGB(45,  45,  45),
    BORDER2    = Color3.fromRGB(65,  65,  65),
    TEXT       = Color3.fromRGB(235, 235, 235),
    TEXT2      = Color3.fromRGB(150, 150, 150),
    TEXT3      = Color3.fromRGB(90,  90,  90),
    ACCENT     = Color3.fromRGB(230, 230, 230),
    BTN_BLUE   = Color3.fromRGB(0,   122, 204),
    BTN_BLUE_H = Color3.fromRGB(0,   145, 240),
    SUCCESS    = Color3.fromRGB(80,  200, 120),
    WARNING    = Color3.fromRGB(240, 180,  50),
    ERROR      = Color3.fromRGB(220,  70,  70),
}
local T = GUI.Theme

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = parent
    return c
end

local function stroke(parent, thickness, color)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = color or T.BORDER
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function label(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamMedium
    l.TextColor3 = T.TEXT
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    for k, v in pairs(props or {}) do l[k] = v end
    l.Parent = parent
    return l
end

local function btn(parent, props)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = T.SURFACE2
    b.Font = Enum.Font.GothamMedium
    b.TextColor3 = T.TEXT
    b.TextSize = 13
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    for k, v in pairs(props or {}) do b[k] = v end
    b.Parent = parent
    corner(b, 5)
    return b
end

local function addButtonFX(b, normalBG, hoverBG, pressBG)
    normalBG = normalBG or b.BackgroundColor3
    hoverBG  = hoverBG  or Color3.new(
        math.min(normalBG.R+0.06,1),
        math.min(normalBG.G+0.06,1),
        math.min(normalBG.B+0.06,1))
    pressBG  = pressBG  or Color3.new(
        math.max(normalBG.R-0.04,0),
        math.max(normalBG.G-0.04,0),
        math.max(normalBG.B-0.04,0))
    local function tween(c) TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3=c}):Play() end
    b.MouseEnter:Connect(function()       tween(hoverBG)  end)
    b.MouseLeave:Connect(function()       tween(normalBG) end)
    b.MouseButton1Down:Connect(function() tween(pressBG)  end)
    b.MouseButton1Up:Connect(function()   tween(hoverBG)  end)
end

GUI.corner      = corner
GUI.stroke      = stroke
GUI.label       = label
GUI.btn         = btn
GUI.addButtonFX = addButtonFX

-- Root ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VCPViewer"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")
GUI.screenGui = screenGui

-- ── Main Frame ──────────────────────────────────────────────────────
local MAIN_W = 420

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, MAIN_W, 0, 52)
mainFrame.Position = UDim2.new(0.5, -MAIN_W/2, 0.5, -26)
mainFrame.BackgroundColor3 = T.BG
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
corner(mainFrame, 10)
stroke(mainFrame, 1, T.BORDER)
GUI.mainFrame = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,52)
header.BackgroundColor3 = T.SURFACE
header.BorderSizePixel = 0
header.Parent = mainFrame
corner(header, 10)
local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1,0,0,10)
hFix.Position = UDim2.new(0,0,1,-10)
hFix.BackgroundColor3 = T.SURFACE
hFix.BorderSizePixel = 0
hFix.Parent = header
GUI.header = header

label(header, {
    Text = "VCP Viewer",
    Size = UDim2.new(1,-60,1,0),
    Position = UDim2.new(0,16,0,0),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
})

local closeBtn = btn(header, {
    Text = "✕",
    Size = UDim2.new(0,28,0,28),
    Position = UDim2.new(1,-36,0.5,-14),
    BackgroundColor3 = T.SURFACE2,
    TextColor3 = T.TEXT2,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
})
addButtonFX(closeBtn, T.SURFACE2, T.BORDER, T.BORDER2)

local sep0 = Instance.new("Frame")
sep0.Size = UDim2.new(1,0,0,1)
sep0.Position = UDim2.new(0,0,0,52)
sep0.BackgroundColor3 = T.BORDER
sep0.BorderSizePixel = 0
sep0.Parent = mainFrame

-- Toolbar
local toolbar = Instance.new("Frame")
toolbar.Name = "Toolbar"
toolbar.Size = UDim2.new(1,0,0,42)
toolbar.Position = UDim2.new(0,0,0,53)
toolbar.BackgroundTransparency = 1
toolbar.Parent = mainFrame
GUI.toolbar = toolbar

local vcpBtn = btn(toolbar, {
    Text = "VCP",
    Size = UDim2.new(0,46,0,30),
    Position = UDim2.new(0,8,0.5,-15),
    BackgroundColor3 = T.BTN_BLUE,
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    Visible = false,
})
addButtonFX(vcpBtn, T.BTN_BLUE, T.BTN_BLUE_H, Color3.fromRGB(0,100,180))
GUI.vcpBtn = vcpBtn

local viewerDropBtn = btn(toolbar, {
    Text = "Viewer  ▾",
    Size = UDim2.new(0,110,0,30),
    Position = UDim2.new(0,8,0.5,-15),
    BackgroundColor3 = T.SURFACE2,
})
addButtonFX(viewerDropBtn, T.SURFACE2, T.BORDER, T.BORDER2)
stroke(viewerDropBtn, 1, T.BORDER)
GUI.viewerDropBtn = viewerDropBtn

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1,-170,0,30)
searchBox.Position = UDim2.new(0,126,0.5,-15)
searchBox.BackgroundColor3 = T.SURFACE2
searchBox.TextColor3 = T.TEXT
searchBox.PlaceholderText = "URL or ID..."
searchBox.PlaceholderColor3 = T.TEXT3
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.ClearTextOnFocus = false
searchBox.BorderSizePixel = 0
searchBox.Parent = toolbar
corner(searchBox, 5)
local sbStroke = stroke(searchBox, 1, T.BORDER)
local sbPad = Instance.new("UIPadding")
sbPad.PaddingLeft = UDim.new(0,8)
sbPad.PaddingRight = UDim.new(0,8)
sbPad.Parent = searchBox
searchBox.Focused:Connect(function()
    TweenService:Create(sbStroke, TweenInfo.new(0.15), {Color=T.BORDER2}):Play()
end)
searchBox.FocusLost:Connect(function()
    TweenService:Create(sbStroke, TweenInfo.new(0.15), {Color=T.BORDER}):Play()
end)
GUI.searchBox = searchBox

local goBtn = btn(toolbar, {
    Text = "→",
    Size = UDim2.new(0,30,0,30),
    Position = UDim2.new(1,-38,0.5,-15),
    BackgroundColor3 = T.SURFACE2,
    TextColor3 = T.TEXT2,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
})
addButtonFX(goBtn, T.SURFACE2, T.BORDER, T.BORDER2)
stroke(goBtn, 1, T.BORDER)
GUI.goBtn = goBtn

local sep1 = Instance.new("Frame")
sep1.Size = UDim2.new(1,0,0,1)
sep1.Position = UDim2.new(0,0,0,95)
sep1.BackgroundColor3 = T.BORDER
sep1.BorderSizePixel = 0
sep1.Parent = mainFrame

-- Content scroll
local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Name = "Content"
contentScroll.Size = UDim2.new(1,0,1,-96)
contentScroll.Position = UDim2.new(0,0,0,96)
contentScroll.BackgroundTransparency = 1
contentScroll.ScrollBarThickness = 3
contentScroll.ScrollBarImageColor3 = T.BORDER2
contentScroll.CanvasSize = UDim2.new(0,0,0,0)
contentScroll.BorderSizePixel = 0
contentScroll.Parent = mainFrame
GUI.contentScroll = contentScroll

-- Drag logic
do
    local dragging, dragStart, startPos
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos  = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end
    header.InputBegan:Connect(onInput)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Viewer dropdown
local VIEWER_MODES = {"Catalog", "Game", "Player | Community"}
local vmCallbacks  = {}

local viewerMenu = Instance.new("Frame")
viewerMenu.Size = UDim2.new(0,180,0,#VIEWER_MODES*34+8)
viewerMenu.BackgroundColor3 = T.SURFACE2
viewerMenu.BorderSizePixel = 0
viewerMenu.Visible = false
viewerMenu.ZIndex = 20
viewerMenu.Parent = screenGui
corner(viewerMenu, 8)
stroke(viewerMenu, 1, T.BORDER)

local vmL = Instance.new("UIListLayout")
vmL.Padding = UDim.new(0,2)
vmL.Parent = viewerMenu
local vmP = Instance.new("UIPadding")
vmP.PaddingTop=UDim.new(0,4) vmP.PaddingBottom=UDim.new(0,4)
vmP.PaddingLeft=UDim.new(0,4) vmP.PaddingRight=UDim.new(0,4)
vmP.Parent = viewerMenu

for _, modeName in ipairs(VIEWER_MODES) do
    local item = btn(viewerMenu, {
        Text = modeName,
        Size = UDim2.new(1,0,0,30),
        BackgroundColor3 = T.SURFACE2,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 21,
    })
    local ip = Instance.new("UIPadding")
    ip.PaddingLeft = UDim.new(0,10)
    ip.Parent = item
    addButtonFX(item, T.SURFACE2, T.BORDER, T.SURFACE)
    item.MouseButton1Click:Connect(function()
        GUI.currentMode = modeName
        viewerDropBtn.Text = modeName .. "  ▾"
        viewerMenu.Visible = false
        local isGame = (modeName == "Game")
        vcpBtn.Visible = isGame
        if isGame then
            viewerDropBtn.Position = UDim2.new(0,62,0.5,-15)
            viewerDropBtn.Size = UDim2.new(0,90,0,30)
            searchBox.Position = UDim2.new(0,160,0.5,-15)
            searchBox.Size = UDim2.new(1,-206,0,30)
        else
            viewerDropBtn.Position = UDim2.new(0,8,0.5,-15)
            viewerDropBtn.Size = UDim2.new(0,140,0,30)
            searchBox.Position = UDim2.new(0,156,0.5,-15)
            searchBox.Size = UDim2.new(1,-202,0,30)
        end
        if vmCallbacks[modeName] then vmCallbacks[modeName]() end
    end)
end

GUI.setModeCallback = function(mn, cb) vmCallbacks[mn] = cb end

viewerDropBtn.MouseButton1Click:Connect(function()
    local abs = viewerDropBtn.AbsolutePosition
    local sz  = viewerDropBtn.AbsoluteSize
    viewerMenu.Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 4)
    viewerMenu.Visible = not viewerMenu.Visible
end)

-- Mini GUI registry + outside-click close
GUI.miniGuis = {}

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local pos = input.Position

    if viewerMenu.Visible then
        local a,s = viewerMenu.AbsolutePosition, viewerMenu.AbsoluteSize
        if pos.X<a.X or pos.X>a.X+s.X or pos.Y<a.Y or pos.Y>a.Y+s.Y then
            viewerMenu.Visible = false
        end
    end

    for i = #GUI.miniGuis, 1, -1 do
        local mg = GUI.miniGuis[i]
        if mg and mg.Parent then
            if mg.Visible then
                local a,s = mg.AbsolutePosition, mg.AbsoluteSize
                if pos.X<a.X or pos.X>a.X+s.X or pos.Y<a.Y or pos.Y>a.Y+s.Y then
                    mg.Visible = false
                end
            end
        else
            table.remove(GUI.miniGuis, i)
        end
    end
end)

function GUI.createMiniGui(items, anchorPos)
    local mg = Instance.new("Frame")
    mg.Size = UDim2.new(0,210,0,#items*36+8)
    mg.BackgroundColor3 = T.SURFACE2
    mg.BorderSizePixel = 0
    mg.ZIndex = 50
    mg.Visible = false
    mg.Parent = screenGui
    corner(mg, 8)
    stroke(mg, 1, T.BORDER)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,2)
    layout.Parent = mg
    local pad = Instance.new("UIPadding")
    pad.PaddingTop=UDim.new(0,4) pad.PaddingBottom=UDim.new(0,4)
    pad.PaddingLeft=UDim.new(0,4) pad.PaddingRight=UDim.new(0,4)
    pad.Parent = mg

    for _, item in ipairs(items) do
        local row = btn(mg, {
            Text = (item.icon or "") .. "  " .. item.text,
            Size = UDim2.new(1,0,0,30),
            BackgroundColor3 = T.SURFACE2,
            TextColor3 = T.TEXT,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 51,
        })
        local rp = Instance.new("UIPadding")
        rp.PaddingLeft = UDim.new(0,8)
        rp.Parent = row
        addButtonFX(row, T.SURFACE2, T.BORDER, T.SURFACE)
        row.MouseButton1Click:Connect(function()
            mg.Visible = false
            if item.callback then item.callback() end
        end)
    end

    if anchorPos then
        local x, y = anchorPos.X, anchorPos.Y + 24
        local ss = screenGui.AbsoluteSize
        if x + 210 > ss.X then x = ss.X - 214 end
        if y + (#items*36+8) > ss.Y then y = anchorPos.Y - (#items*36+8) - 4 end
        mg.Position = UDim2.new(0,x,0,y)
    end

    table.insert(GUI.miniGuis, mg)
    return mg
end

-- Side GUI
GUI.activeSideGui = nil
function GUI.openSideGui(title, buildFn)
    if GUI.activeSideGui then GUI.activeSideGui:Destroy() GUI.activeSideGui = nil end

    local SIDE_W = 260
    local mAbs = mainFrame.AbsolutePosition
    local mSz  = mainFrame.AbsoluteSize

    local sg = Instance.new("Frame")
    sg.Size = UDim2.new(0,SIDE_W,0,mSz.Y)
    sg.Position = UDim2.new(0,mAbs.X-10,0,mAbs.Y)
    sg.BackgroundColor3 = T.BG
    sg.BorderSizePixel = 0
    sg.ClipsDescendants = true
    sg.Parent = screenGui
    corner(sg, 10)
    stroke(sg, 1, T.BORDER)
    GUI.activeSideGui = sg

    local sgH = Instance.new("Frame")
    sgH.Size = UDim2.new(1,0,0,42)
    sgH.BackgroundColor3 = T.SURFACE
    sgH.BorderSizePixel = 0
    sgH.Parent = sg
    corner(sgH, 10)
    local hfix = Instance.new("Frame")
    hfix.Size = UDim2.new(1,0,0,10)
    hfix.Position = UDim2.new(0,0,1,-10)
    hfix.BackgroundColor3 = T.SURFACE
    hfix.BorderSizePixel = 0
    hfix.Parent = sgH

    label(sgH, {Text=title, Size=UDim2.new(1,-40,1,0), Position=UDim2.new(0,12,0,0), Font=Enum.Font.GothamBold, TextSize=13})

    local sgClose = btn(sgH, {
        Text="✕", Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-32,0.5,-13),
        BackgroundColor3=T.SURFACE2, TextColor3=T.TEXT2, TextSize=11
    })
    addButtonFX(sgClose, T.SURFACE2, T.BORDER, T.BORDER2)
    sgClose.MouseButton1Click:Connect(function() sg:Destroy() GUI.activeSideGui=nil end)

    local s2 = Instance.new("Frame")
    s2.Size = UDim2.new(1,0,0,1)
    s2.Position = UDim2.new(0,0,0,42)
    s2.BackgroundColor3 = T.BORDER
    s2.BorderSizePixel = 0
    s2.Parent = sg

    local sgScroll = Instance.new("ScrollingFrame")
    sgScroll.Size = UDim2.new(1,0,1,-43)
    sgScroll.Position = UDim2.new(0,0,0,43)
    sgScroll.BackgroundTransparency = 1
    sgScroll.ScrollBarThickness = 3
    sgScroll.ScrollBarImageColor3 = T.BORDER2
    sgScroll.CanvasSize = UDim2.new(0,0,0,0)
    sgScroll.BorderSizePixel = 0
    sgScroll.Parent = sg

    if buildFn then buildFn(sgScroll) end

    TweenService:Create(sg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0,mAbs.X-SIDE_W-10,0,mAbs.Y)}):Play()

    return sg, sgScroll
end

-- Content helpers
function GUI.clearContent()
    for _, c in ipairs(contentScroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    contentScroll.CanvasSize = UDim2.new(0,0,0,0)
end

function GUI.setMainHeight(h)
    TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        {Size = UDim2.new(0,MAIN_W,0,h)}):Play()
end

function GUI.showLoading()
    GUI.clearContent()
    GUI.setMainHeight(150)
    label(contentScroll, {
        Text="Loading…", Size=UDim2.new(1,0,0,50), Position=UDim2.new(0,0,0,20),
        TextColor3=T.TEXT3, TextXAlignment=Enum.TextXAlignment.Center, TextSize=13,
    })
end

function GUI.showError(msg)
    GUI.clearContent()
    GUI.setMainHeight(130)
    label(contentScroll, {
        Text="⚠", Size=UDim2.new(1,0,0,28), Position=UDim2.new(0,0,0,12),
        TextColor3=T.WARNING, TextXAlignment=Enum.TextXAlignment.Center, TextSize=22,
    })
    label(contentScroll, {
        Text=msg or "Something went wrong.",
        Size=UDim2.new(1,-32,0,50), Position=UDim2.new(0,16,0,44),
        TextColor3=T.TEXT2, TextXAlignment=Enum.TextXAlignment.Center,
        TextWrapped=true, TextSize=12,
    })
end

function GUI.makeIcon(parent, size, pos, imageId)
    local frame = Instance.new("Frame")
    frame.Size = size; frame.Position = pos
    frame.BackgroundColor3 = T.SURFACE2
    frame.BorderSizePixel = 0
    frame.Parent = parent
    corner(frame, 8)
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1,0,1,0)
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = frame
    corner(img, 8)
    if imageId then img.Image = imageId end
    return frame, img
end

function GUI.makeCopyIcon(parent, pos, menuItems)
    local cb = btn(parent, {
        Text="⧉", Size=UDim2.new(0,20,0,20),
        BackgroundTransparency=1, TextColor3=T.TEXT3, TextSize=14,
    })
    cb.Position = pos
    cb.MouseEnter:Connect(function() cb.TextColor3=T.TEXT end)
    cb.MouseLeave:Connect(function() cb.TextColor3=T.TEXT3 end)
    cb.MouseButton1Click:Connect(function()
        local mg = GUI.createMiniGui(menuItems, cb.AbsolutePosition)
        mg.Visible = true
    end)
    return cb
end

function GUI.makeRow(parent, y, key, value, copyMenuItems)
    label(parent, {
        Text=key, Size=UDim2.new(0,90,0,22), Position=UDim2.new(0,0,0,y),
        TextColor3=T.TEXT3, TextSize=12,
    })
    local valL = label(parent, {
        Text=value or "—",
        Size=UDim2.new(1,(copyMenuItems and -116 or -96),0,22),
        Position=UDim2.new(0,94,0,y),
        TextColor3=T.TEXT, TextSize=12, TextTruncate=Enum.TextTruncate.AtEnd,
    })
    local copyBtn
    if copyMenuItems then
        copyBtn = GUI.makeCopyIcon(parent, UDim2.new(1,-22,0,y+1), copyMenuItems)
    end
    return nil, valL, copyBtn
end

-- Close
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Open animation
mainFrame.BackgroundTransparency = 1
TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {BackgroundTransparency=0}):Play()

return GUI
end)()

-- ════════════════════════════════════════════════════════════════════
--  [2]  CATALOG VIEWER
-- ════════════════════════════════════════════════════════════════════
local CatalogViewer = (function()
local M = {}
local HttpService = game:GetService("HttpService")

local function httpGet(u) local ok,r=pcall(function()return game:HttpGet(u)end) return ok and r or nil end
local function jd(s) local ok,r=pcall(HttpService.JSONDecode,HttpService,s) return ok and r or nil end
local function fmtDate(iso)
    if not iso then return "—" end
    local y,m,d=iso:match("(%d+)-(%d+)-(%d+)") if not y then return iso end
    local mn={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return d.." "..mn[tonumber(m)].." "..y
end
local function fmtDT(iso)
    if not iso then return "—" end
    local y,m,d,h,mi,s=iso:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)") if not y then return fmtDate(iso) end
    local mn={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return d.." "..mn[tonumber(m)].." "..y.."  "..h..":"..mi..":"..s
end
local function extractId(i)
    return i:match("catalog/(%d+)") or (i:match("^%d+$") and i or nil)
end

local ECON = "https://economy.roblox.com/v2/assets/%s/details"
local THUMB = "https://thumbnails.roblox.com/v1/assets?assetIds=%s&size=150x150&format=Png"

function M.load(GUI, assetId)
    local T = GUI.Theme
    GUI.showLoading()
    task.spawn(function()
        local raw = httpGet(ECON:format(assetId))
        if not raw then GUI.showError("Failed to fetch asset. Is HttpEnabled on?") return end
        local data = jd(raw)
        if not data or data.errors then GUI.showError("Asset not found.") return end

        local thumbUrl = ""
        local tr = httpGet(THUMB:format(assetId))
        if tr then local td=jd(tr) if td and td.data and td.data[1] then thumbUrl=td.data[1].imageUrl or "" end end

        local creatorName = data.Creator and data.Creator.Name or "Unknown"
        local creatorId   = data.Creator and data.Creator.CreatorTargetId
        local creatorType = data.Creator and data.Creator.CreatorType

        GUI.clearContent()
        local cs = GUI.contentScroll

        GUI.makeIcon(cs, UDim2.new(0,90,0,90), UDim2.new(0,12,0,12), thumbUrl~="" and thumbUrl or nil)

        local info = Instance.new("Frame")
        info.Size = UDim2.new(1,-116,0,600)
        info.Position = UDim2.new(0,110,0,8)
        info.BackgroundTransparency = 1
        info.Parent = cs

        local y = 0

        GUI.makeRow(info,y,"Name",data.Name or "—",{
            {icon="⧉",text="Copy Roblox Link",callback=function() setclipboard("https://www.roblox.com/catalog/"..assetId) end},
            {icon="📊",text="Copy Rolimons Link",callback=function() setclipboard("https://www.rolimons.com/item/"..assetId) end},
        }) y=y+26

        GUI.makeRow(info,y,"Created by",creatorName,{
            {icon="⧉",text="Copy Roblox Link",callback=function()
                if creatorType=="Group" then setclipboard("https://www.roblox.com/groups/"..(creatorId or ""))
                else setclipboard("https://www.roblox.com/users/"..(creatorId or "").."/profile") end end},
            {icon="📊",text="Copy Rolimons Link",callback=function()
                if creatorType=="Group" then setclipboard("https://www.rolimons.com/group/"..(creatorId or ""))
                else setclipboard("https://www.rolimons.com/player/"..(creatorId or "")) end end},
            {icon="→",text="View Profile",callback=function() if GUI.onViewCreator then GUI.onViewCreator(creatorType,creatorId) end end},
        }) y=y+26

        GUI.makeRow(info,y,"Created at",fmtDate(data.Created)) y=y+26

        local _,uaV = GUI.makeRow(info,y,"Updated at","—") y=y+26
        task.spawn(function()
            while uaV and uaV.Parent do
                local fr=httpGet(ECON:format(assetId))
                if fr then local fd=jd(fr) if fd and fd.Updated then uaV.Text=fmtDT(fd.Updated) end end
                task.wait(30)
            end
        end)

        if data.PriceInRobux then GUI.makeRow(info,y,"Price","R$ "..tostring(data.PriceInRobux)) y=y+26 end
        if data.Sales then GUI.makeRow(info,y,"Sales",tostring(data.Sales)) y=y+26 end

        local div=Instance.new("Frame") div.Size=UDim2.new(1,-12,0,1) div.Position=UDim2.new(0,0,0,y+4)
        div.BackgroundColor3=T.BORDER div.BorderSizePixel=0 div.Parent=info y=y+14

        GUI.label(info,{Text="Description",Size=UDim2.new(1,-12,0,18),Position=UDim2.new(0,0,0,y),
            TextColor3=T.TEXT3,TextSize=11,Font=Enum.Font.GothamBold}) y=y+20

        local db=Instance.new("TextLabel")
        db.Size=UDim2.new(1,-12,0,80) db.Position=UDim2.new(0,0,0,y)
        db.BackgroundColor3=T.SURFACE2 db.BorderSizePixel=0 db.TextColor3=T.TEXT2
        db.Font=Enum.Font.Gotham db.TextSize=11 db.TextXAlignment=Enum.TextXAlignment.Left
        db.TextYAlignment=Enum.TextYAlignment.Top db.TextWrapped=true db.Parent=info
        db.Text=(data.Description and data.Description~="") and data.Description or "(No description)"
        GUI.corner(db,6)
        local dp=Instance.new("UIPadding") dp.PaddingLeft=UDim.new(0,6) dp.PaddingRight=UDim.new(0,6)
        dp.PaddingTop=UDim.new(0,5) dp.PaddingBottom=UDim.new(0,5) dp.Parent=db
        y=y+88

        cs.CanvasSize=UDim2.new(0,0,0,y+16)
        GUI.setMainHeight(math.min(96+y+32,600))
    end)
end

function M.init(GUI)
    GUI.searchBox.PlaceholderText = "Asset URL or ID…"
    GUI.goBtn.MouseButton1Click:Connect(function()
        local i=GUI.searchBox.Text:match("^%s*(.-)%s*$") if i=="" then return end
        local id=extractId(i) if not id then GUI.showError("Invalid input.") return end
        M.load(GUI, id)
    end)
end

return M
end)()

-- ════════════════════════════════════════════════════════════════════
--  [3]  GAME VIEWER
-- ════════════════════════════════════════════════════════════════════
local GameViewer = (function()
local M = {}
local HttpService    = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player  = Players.LocalPlayer

local function httpGet(u) local ok,r=pcall(function()return game:HttpGet(u)end) return ok and r or nil end
local function jd(s) local ok,r=pcall(HttpService.JSONDecode,HttpService,s) return ok and r or nil end
local function fmtDate(iso)
    if not iso then return "—" end
    local y,m,d=iso:match("(%d+)-(%d+)-(%d+)") if not y then return iso end
    local mn={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return d.." "..mn[tonumber(m)].." "..y
end
local function fmtDT(iso)
    if not iso then return "—" end
    local y,m,d,h,mi,s=iso:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)") if not y then return fmtDate(iso) end
    local mn={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return d.." "..mn[tonumber(m)].." "..y.."  "..h..":"..mi..":"..s
end
local function extractId(i) return i:match("games/(%d+)") or (i:match("^%d+$") and i or nil) end

local GAMES_API    = "https://games.roblox.com/v1/games?universeIds=%s"
local UNIVERSE_API = "https://apis.roblox.com/universes/v1/places/%s/universe"
local THUMB_API    = "https://thumbnails.roblox.com/v1/games/icons?universeIds=%s&size=150x150&format=Png"
local SUBPLACES    = "https://games.roblox.com/v1/games/%s/subplaces?sortOrder=Asc&limit=50"

local function teleportTo(id) pcall(function() TeleportService:Teleport(tonumber(id),player) end) end
local function copyTPScript(id) setclipboard('game:GetService("TeleportService"):Teleport('..id..', game.Players.LocalPlayer)') end

local function openSubPlaces(GUI, universeId, currentId)
    local T = GUI.Theme
    local raw = httpGet(SUBPLACES:format(universeId))
    if not raw then GUI.showError("Failed to load sub places.") return end
    local data = jd(raw)
    if not data or not data.data then GUI.showError("No sub places.") return end

    GUI.openSideGui("Sub Places", function(scroll)
        local ly = Instance.new("UIListLayout") ly.Padding=UDim.new(0,4) ly.Parent=scroll
        local pd = Instance.new("UIPadding") pd.PaddingTop=UDim.new(0,6) pd.PaddingLeft=UDim.new(0,6) pd.PaddingRight=UDim.new(0,6) pd.Parent=scroll
        local totalH = 0
        for _, place in ipairs(data.data) do
            local pid   = tostring(place.id or place.placeId or "")
            local pname = place.name or ("Place "..pid)
            local here  = (pid==tostring(currentId))
            local row = Instance.new("Frame")
            row.Size=UDim2.new(1,-12,0,54) row.BackgroundColor3=T.SURFACE2 row.BorderSizePixel=0 row.Parent=scroll
            GUI.corner(row,8)
            GUI.label(row,{Text=pname..(here and "  ✓" or ""),Size=UDim2.new(1,-44,0,22),Position=UDim2.new(0,8,0,4),
                TextColor3=here and T.SUCCESS or T.TEXT,TextSize=12,Font=Enum.Font.GothamMedium,TextTruncate=Enum.TextTruncate.AtEnd})
            GUI.label(row,{Text="ID: "..pid,Size=UDim2.new(1,-44,0,16),Position=UDim2.new(0,8,0,28),TextColor3=T.TEXT3,TextSize=10})
            local mb = GUI.btn(row,{Text="•••",Size=UDim2.new(0,32,0,22),Position=UDim2.new(1,-38,0.5,-11),
                BackgroundColor3=T.SURFACE,TextColor3=T.TEXT2,TextSize=12,ZIndex=5})
            GUI.addButtonFX(mb,T.SURFACE,T.BORDER,T.BORDER2)
            mb.MouseButton1Click:Connect(function()
                local mg=GUI.createMiniGui({
                    {icon="🚀",text="Teleport",callback=function()teleportTo(pid)end},
                    {icon="⧉",text="Copy Script",callback=function()copyTPScript(pid)end},
                },mb.AbsolutePosition)
                mg.Visible=true
            end)
            totalH=totalH+58
        end
        scroll.CanvasSize=UDim2.new(0,0,0,totalH+12)
    end)
end

function M.load(GUI, placeId, isVCP)
    local T = GUI.Theme
    GUI.showLoading()
    task.spawn(function()
        local uniRaw = httpGet(UNIVERSE_API:format(placeId))
        local universeId = placeId
        if uniRaw then local ud=jd(uniRaw) if ud and ud.universeId then universeId=tostring(ud.universeId) end end

        local raw = httpGet(GAMES_API:format(universeId))
        if not raw then GUI.showError("Failed to fetch game.") return end
        local data = jd(raw)
        if not data or not data.data or #data.data==0 then GUI.showError("Game not found.") return end
        local gd = data.data[1]

        local thumbUrl=""
        local tr=httpGet(THUMB_API:format(universeId))
        if tr then local td=jd(tr) if td and td.data and td.data[1] then thumbUrl=td.data[1].imageUrl or "" end end

        local creatorName = gd.creator and gd.creator.name or "Unknown"
        local creatorId   = gd.creator and gd.creator.id
        local creatorType = gd.creator and gd.creator.type

        GUI.clearContent()
        local cs = GUI.contentScroll
        GUI.makeIcon(cs,UDim2.new(0,90,0,90),UDim2.new(0,12,0,12),thumbUrl~="" and thumbUrl or nil)

        local info=Instance.new("Frame")
        info.Size=UDim2.new(1,-116,0,600) info.Position=UDim2.new(0,110,0,8)
        info.BackgroundTransparency=1 info.Parent=cs

        local y=0

        GUI.makeRow(info,y,"Name",gd.name or "—",{
            {icon="⧉",text="Copy Roblox Link",callback=function()setclipboard("https://www.roblox.com/games/"..placeId)end},
            {icon="📊",text="Copy Rolimons Link",callback=function()setclipboard("https://www.rolimons.com/game/"..universeId)end},
        }) y=y+26

        GUI.makeRow(info,y,"Created by",creatorName,{
            {icon="⧉",text="Copy Roblox Link",callback=function()
                if creatorType=="Group" then setclipboard("https://www.roblox.com/groups/"..tostring(creatorId or ""))
                else setclipboard("https://www.roblox.com/users/"..tostring(creatorId or "").."/profile") end end},
            {icon="📊",text="Copy Rolimons Link",callback=function()
                if creatorType=="Group" then setclipboard("https://www.rolimons.com/group/"..tostring(creatorId or ""))
                else setclipboard("https://www.rolimons.com/player/"..tostring(creatorId or "")) end end},
            {icon="→",text="View Profile",callback=function() if GUI.onViewCreator then GUI.onViewCreator(creatorType,creatorId) end end},
        }) y=y+26

        GUI.makeRow(info,y,"Created at",fmtDate(gd.created)) y=y+26

        local _,uaV=GUI.makeRow(info,y,"Updated at","—") y=y+26
        task.spawn(function()
            while uaV and uaV.Parent do
                local fr=httpGet(GAMES_API:format(universeId))
                if fr then local fd=jd(fr) if fd and fd.data and fd.data[1] then uaV.Text=fmtDT(fd.data[1].updated) end end
                task.wait(30)
            end
        end)

        if gd.playing   then GUI.makeRow(info,y,"Playing",tostring(gd.playing))     y=y+26 end
        if gd.visits    then GUI.makeRow(info,y,"Visits",tostring(gd.visits))        y=y+26 end
        if gd.maxPlayers then GUI.makeRow(info,y,"Max Players",tostring(gd.maxPlayers)) y=y+26 end

        local div=Instance.new("Frame") div.Size=UDim2.new(1,-12,0,1) div.Position=UDim2.new(0,0,0,y+4)
        div.BackgroundColor3=T.BORDER div.BorderSizePixel=0 div.Parent=info y=y+14

        GUI.label(info,{Text="Description",Size=UDim2.new(1,-12,0,18),Position=UDim2.new(0,0,0,y),
            TextColor3=T.TEXT3,TextSize=11,Font=Enum.Font.GothamBold}) y=y+20

        local db=Instance.new("TextLabel")
        db.Size=UDim2.new(1,-12,0,80) db.Position=UDim2.new(0,0,0,y)
        db.BackgroundColor3=T.SURFACE2 db.BorderSizePixel=0 db.TextColor3=T.TEXT2
        db.Font=Enum.Font.Gotham db.TextSize=11 db.TextXAlignment=Enum.TextXAlignment.Left
        db.TextYAlignment=Enum.TextYAlignment.Top db.TextWrapped=true db.Parent=info
        db.Text=(gd.description and gd.description~="") and gd.description or "(No description)"
        GUI.corner(db,6)
        local dp=Instance.new("UIPadding") dp.PaddingLeft=UDim.new(0,6) dp.PaddingRight=UDim.new(0,6)
        dp.PaddingTop=UDim.new(0,5) dp.PaddingBottom=UDim.new(0,5) dp.Parent=db
        y=y+88

        -- Blue action button
        local currentId = game.PlaceId
        local canSub = (tostring(currentId)==tostring(placeId))

        local ab=Instance.new("TextButton")
        ab.Size=UDim2.new(0,28,0,28) ab.Position=UDim2.new(0,0,0,y+4)
        ab.BackgroundColor3=T.BTN_BLUE ab.TextColor3=Color3.fromRGB(255,255,255)
        ab.Text="›" ab.Font=Enum.Font.GothamBold ab.TextSize=20 ab.BorderSizePixel=0 ab.Parent=info
        GUI.corner(ab,6) GUI.addButtonFX(ab,T.BTN_BLUE,T.BTN_BLUE_H,Color3.fromRGB(0,100,180))
        y=y+40

        ab.MouseButton1Click:Connect(function()
            local items={
                {icon="🚀",text="Teleport",callback=function()teleportTo(placeId)end},
                {icon="⧉",text="Copy Teleport Script",callback=function()copyTPScript(placeId)end},
            }
            if canSub then
                table.insert(items,{icon="📂",text="Sub Places",callback=function()
                    openSubPlaces(GUI,universeId,currentId)
                end})
            end
            local mg=GUI.createMiniGui(items,ab.AbsolutePosition)
            mg.Visible=true
        end)

        cs.CanvasSize=UDim2.new(0,0,0,y+16)
        GUI.setMainHeight(math.min(96+y+32,620))
    end)
end

function M.init(GUI)
    GUI.searchBox.PlaceholderText = "Game URL or Place ID…"
    GUI.vcpBtn.MouseButton1Click:Connect(function()
        local id=tostring(game.PlaceId)
        GUI.searchBox.Text=id
        M.load(GUI,id,true)
    end)
    GUI.goBtn.MouseButton1Click:Connect(function()
        local i=GUI.searchBox.Text:match("^%s*(.-)%s*$") if i=="" then return end
        local id=extractId(i) if not id then GUI.showError("Invalid input.") return end
        M.load(GUI,id,false)
    end)
end

return M
end)()

-- ════════════════════════════════════════════════════════════════════
--  [4]  PLAYER | COMMUNITY VIEWER
-- ════════════════════════════════════════════════════════════════════
local PCViewer = (function()
local M = {}
local HttpService = game:GetService("HttpService")

local function httpGet(u) local ok,r=pcall(function()return game:HttpGet(u)end) return ok and r or nil end
local function jd(s) local ok,r=pcall(HttpService.JSONDecode,HttpService,s) return ok and r or nil end
local function fmtDate(iso)
    if not iso then return "—" end
    local y,m,d=iso:match("(%d+)-(%d+)-(%d+)") if not y then return iso end
    local mn={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return d.." "..mn[tonumber(m)].." "..y
end

local USER_BY_ID  = "https://users.roblox.com/v1/users/%s"
local USER_SEARCH = "https://users.roblox.com/v1/users/search?keyword=%s&limit=1"
local USER_THUMB  = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%s&size=150x150&format=Png"
local GROUP_BY_ID = "https://groups.roblox.com/v1/groups/%s"
local GROUP_THUMB = "https://thumbnails.roblox.com/v1/groups/icons?groupIds=%s&size=150x150&format=Png"

local function parseInput(input)
    local uid=input:match("roblox%.com/users/(%d+)") if uid then return "user",uid end
    local gid=input:match("roblox%.com/groups?/(%d+)") if gid then return "group",gid end
    if input:match("^%d+$") then return "ambiguous",input end
    if input:match("^[%w_]+$") then return "username",input end
    return nil,nil
end

local function buildInfo(GUI, cs, userId, groupId, data, thumbUrl, isGroup)
    local T = GUI.Theme
    GUI.makeIcon(cs,UDim2.new(0,80,0,80),UDim2.new(0,12,0,12),thumbUrl~="" and thumbUrl or nil)

    local info=Instance.new("Frame")
    info.Size=UDim2.new(1,-104,0,500) info.Position=UDim2.new(0,100,0,8)
    info.BackgroundTransparency=1 info.Parent=cs

    local y=0

    if isGroup then
        local gid=tostring(groupId)
        GUI.makeRow(info,y,"Name",data.name or "—",{
            {icon="⧉",text="Copy Roblox Link",callback=function()setclipboard("https://www.roblox.com/groups/"..gid)end},
            {icon="📊",text="Copy Rolimons Link",callback=function()setclipboard("https://www.rolimons.com/group/"..gid)end},
        }) y=y+26
        GUI.makeRow(info,y,"Group ID",gid) y=y+26
        local ownerName = data.owner and data.owner.username or "Nobody"
        local ownerId   = data.owner and data.owner.userId
        GUI.makeRow(info,y,"Owner",ownerName,{
            {icon="⧉",text="Copy Roblox Link",callback=function()
                if ownerId then setclipboard("https://www.roblox.com/users/"..tostring(ownerId).."/profile") end end},
            {icon="→",text="View Profile",callback=function()
                if GUI.onViewCreator and ownerId then GUI.onViewCreator("User",ownerId) end end},
        }) y=y+26
        if data.memberCount then GUI.makeRow(info,y,"Members",tostring(data.memberCount)) y=y+26 end
    else
        local uid=tostring(userId)
        GUI.makeRow(info,y,"Name",data.name or "—",{
            {icon="⧉",text="Copy Roblox Link",callback=function()setclipboard("https://www.roblox.com/users/"..uid.."/profile")end},
            {icon="📊",text="Copy Rolimons Link",callback=function()setclipboard("https://www.rolimons.com/player/"..uid)end},
        }) y=y+26
        if data.displayName and data.displayName~=data.name then
            GUI.makeRow(info,y,"Display",data.displayName) y=y+26
        end
        GUI.makeRow(info,y,"User ID",uid) y=y+26
        GUI.makeRow(info,y,"Created",fmtDate(data.created)) y=y+26
        if data.isBanned      then GUI.makeRow(info,y,"Status","⛔ Banned") y=y+26 end
        if data.hasVerifiedBadge then GUI.makeRow(info,y,"Verified","✓ Yes") y=y+26 end
    end

    local div=Instance.new("Frame") div.Size=UDim2.new(1,-12,0,1) div.Position=UDim2.new(0,0,0,y+4)
    div.BackgroundColor3=T.BORDER div.BorderSizePixel=0 div.Parent=info y=y+14

    GUI.label(info,{Text="Description",Size=UDim2.new(1,-12,0,18),Position=UDim2.new(0,0,0,y),
        TextColor3=T.TEXT3,TextSize=11,Font=Enum.Font.GothamBold}) y=y+20

    local descText = (data.description and data.description~="") and data.description
        or ((isGroup and data.description~=nil) and data.description or "(No description)")
    local db=Instance.new("TextLabel")
    db.Size=UDim2.new(1,-12,0,80) db.Position=UDim2.new(0,0,0,y)
    db.BackgroundColor3=T.SURFACE2 db.BorderSizePixel=0 db.TextColor3=T.TEXT2
    db.Font=Enum.Font.Gotham db.TextSize=11 db.TextXAlignment=Enum.TextXAlignment.Left
    db.TextYAlignment=Enum.TextYAlignment.Top db.TextWrapped=true db.Parent=info
    db.Text = descText or "(No description)"
    GUI.corner(db,6)
    local dp=Instance.new("UIPadding") dp.PaddingLeft=UDim.new(0,6) dp.PaddingRight=UDim.new(0,6)
    dp.PaddingTop=UDim.new(0,5) dp.PaddingBottom=UDim.new(0,5) dp.Parent=db
    y=y+88

    cs.CanvasSize=UDim2.new(0,0,0,y+16)
    GUI.setMainHeight(math.min(96+y+32,580))
end

function M.loadUser(GUI, userId)
    GUI.showLoading()
    task.spawn(function()
        local raw=httpGet(USER_BY_ID:format(userId))
        if not raw then GUI.showError("Failed to fetch user.") return end
        local data=jd(raw)
        if not data or data.errors then GUI.showError("User not found.") return end
        local thumbUrl=""
        local tr=httpGet(USER_THUMB:format(userId))
        if tr then local td=jd(tr) if td and td.data and td.data[1] then thumbUrl=td.data[1].imageUrl or "" end end
        GUI.clearContent()
        buildInfo(GUI,GUI.contentScroll,userId,nil,data,thumbUrl,false)
    end)
end

function M.loadGroup(GUI, groupId)
    GUI.showLoading()
    task.spawn(function()
        local raw=httpGet(GROUP_BY_ID:format(groupId))
        if not raw then GUI.showError("Failed to fetch group.") return end
        local data=jd(raw)
        if not data or data.errors then GUI.showError("Group not found.") return end
        local thumbUrl=""
        local tr=httpGet(GROUP_THUMB:format(groupId))
        if tr then local td=jd(tr) if td and td.data and td.data[1] then thumbUrl=td.data[1].imageUrl or "" end end
        GUI.clearContent()
        buildInfo(GUI,GUI.contentScroll,nil,groupId,data,thumbUrl,true)
    end)
end

function M.resolve(GUI, input)
    local kind,id=parseInput(input)
    if not kind then GUI.showError("Invalid input. Use URL, username or ID.") return end

    if kind=="user" then M.loadUser(GUI,id)
    elseif kind=="group" then M.loadGroup(GUI,id)
    elseif kind=="username" then
        GUI.showLoading()
        task.spawn(function()
            local sr=httpGet(USER_SEARCH:format(id))
            if sr then local sd=jd(sr) if sd and sd.data and #sd.data>0 then M.loadUser(GUI,tostring(sd.data[1].id)) return end end
            GUI.showError("Username '"..id.."' not found.")
        end)
    elseif kind=="ambiguous" then
        GUI.showLoading()
        task.spawn(function()
            local ur=httpGet(USER_BY_ID:format(id))
            if ur then local ud=jd(ur) if ud and not ud.errors and ud.name then M.loadUser(GUI,id) return end end
            local gr=httpGet(GROUP_BY_ID:format(id))
            if gr then local gd=jd(gr) if gd and not gd.errors and gd.name then M.loadGroup(GUI,id) return end end
            GUI.showError("ID "..id.." not found.")
        end)
    end
end

function M.init(GUI)
    GUI.searchBox.PlaceholderText = "Profile URL, username or ID…"
    GUI.goBtn.MouseButton1Click:Connect(function()
        local i=GUI.searchBox.Text:match("^%s*(.-)%s*$") if i=="" then return end
        M.resolve(GUI,i)
    end)
end

return M
end)()

-- ════════════════════════════════════════════════════════════════════
--  MAIN WIRING
-- ════════════════════════════════════════════════════════════════════

-- Cross-module: "View Profile" in Game/Catalog opens PC viewer
GUI.onViewCreator = function(creatorType, creatorId)
    if not creatorId then return end
    GUI.currentMode = "Player | Community"
    GUI.viewerDropBtn.Text = "Player | Community  ▾"
    GUI.vcpBtn.Visible = false
    GUI.viewerDropBtn.Position = UDim2.new(0,8,0.5,-15)
    GUI.viewerDropBtn.Size = UDim2.new(0,140,0,30)
    GUI.searchBox.Position = UDim2.new(0,156,0.5,-15)
    GUI.searchBox.Size = UDim2.new(1,-202,0,30)
    PCViewer.init(GUI)
    if creatorType=="Group" or creatorType=="group" then
        PCViewer.loadGroup(GUI,tostring(creatorId))
    else
        PCViewer.loadUser(GUI,tostring(creatorId))
    end
end

-- Mode callbacks
GUI.setModeCallback("Catalog",            function() CatalogViewer.init(GUI) end)
GUI.setModeCallback("Game",               function() GameViewer.init(GUI) end)
GUI.setModeCallback("Player | Community", function() PCViewer.init(GUI) end)

-- Enter key fires goBtn
GUI.searchBox.FocusLost:Connect(function(enter)
    if enter then GUI.goBtn.MouseButton1Click:Fire() end
end)

-- Default mode
CatalogViewer.init(GUI)
GUI.viewerDropBtn.Text = "Catalog  ▾"
GUI.showError("Enter an asset URL or ID to get started.")

-- ╔══════════════════════════════════════════════════════╗
-- ║           VCP VIEWER  —  Module 1: GUI Core          ║
-- ║  Main Frame · Mini GUI · Side GUI · Theme            ║
-- ╚══════════════════════════════════════════════════════╝

local GUI = {}

local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local Players        = game:GetService("Players")
local player         = Players.LocalPlayer

-- ─────────────────────────────────────────
--  THEME
-- ─────────────────────────────────────────
GUI.Theme = {
    BG          = Color3.fromRGB(10,  10,  10),   -- near-black bg
    SURFACE     = Color3.fromRGB(18,  18,  18),   -- panel surface
    SURFACE2    = Color3.fromRGB(26,  26,  26),   -- elevated surface
    BORDER      = Color3.fromRGB(45,  45,  45),   -- subtle border
    BORDER2     = Color3.fromRGB(65,  65,  65),   -- hover border
    TEXT        = Color3.fromRGB(235, 235, 235),  -- primary text
    TEXT2       = Color3.fromRGB(150, 150, 150),  -- secondary text
    TEXT3       = Color3.fromRGB(90,  90,  90),   -- disabled/placeholder
    ACCENT      = Color3.fromRGB(230, 230, 230),  -- white accent
    ACCENT_DIM  = Color3.fromRGB(80,  80,  80),
    BTN_BLUE    = Color3.fromRGB(0,   122, 204),  -- Roblox-style blue
    BTN_BLUE_H  = Color3.fromRGB(0,   145, 240),
    SUCCESS     = Color3.fromRGB(80,  200, 120),
    WARNING     = Color3.fromRGB(240, 180, 50),
    ERROR       = Color3.fromRGB(220, 70,  70),
}
local T = GUI.Theme

-- ─────────────────────────────────────────
--  UTILITY
-- ─────────────────────────────────────────
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

-- Button hover + press feedback
local function addButtonFX(b, normalBG, hoverBG, pressBG)
    normalBG = normalBG or b.BackgroundColor3
    hoverBG  = hoverBG  or Color3.new(normalBG.R+0.06, normalBG.G+0.06, normalBG.B+0.06)
    pressBG  = pressBG  or Color3.new(normalBG.R-0.04, normalBG.G-0.04, normalBG.B-0.04)
    local function tween(c) TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3=c}):Play() end
    b.MouseEnter:Connect(function()    tween(hoverBG)  end)
    b.MouseLeave:Connect(function()    tween(normalBG) end)
    b.MouseButton1Down:Connect(function() tween(pressBG) end)
    b.MouseButton1Up:Connect(function()   tween(hoverBG) end)
end

GUI.corner   = corner
GUI.stroke   = stroke
GUI.label    = label
GUI.btn      = btn
GUI.addButtonFX = addButtonFX

-- ─────────────────────────────────────────
--  ROOT SCREENGUI
-- ─────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VCPViewer"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")
GUI.screenGui = screenGui

-- ─────────────────────────────────────────
--  MAIN FRAME  (draggable)
-- ─────────────────────────────────────────
local MAIN_W = 420
local MAIN_H = 52   -- header-only height; expands when content loads

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
mainFrame.Position = UDim2.new(0.5, -MAIN_W/2, 0.5, -MAIN_H/2)
mainFrame.BackgroundColor3 = T.BG
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
corner(mainFrame, 10)
stroke(mainFrame, 1, T.BORDER)
GUI.mainFrame = mainFrame

-- Header bar (drag handle)
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = T.SURFACE
header.BorderSizePixel = 0
header.Parent = mainFrame
-- top corners only — fake with bottom-flush fix frame
corner(header, 10)
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1,0,0,10)
headerFix.Position = UDim2.new(0,0,1,-10)
headerFix.BackgroundColor3 = T.SURFACE
headerFix.BorderSizePixel = 0
headerFix.Parent = header
GUI.header = header

-- Title label  "VCP Viewer"
local titleLabel = label(header, {
    Text = "VCP Viewer",
    Size = UDim2.new(1, -60, 1, 0),
    Position = UDim2.new(0, 16, 0, 0),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = T.TEXT,
})
GUI.titleLabel = titleLabel

-- Close button
local closeBtn = btn(header, {
    Text = "✕",
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -36, 0.5, -14),
    BackgroundColor3 = T.SURFACE2,
    TextColor3 = T.TEXT2,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
})
addButtonFX(closeBtn, T.SURFACE2, T.BORDER, T.BORDER2)
GUI.closeBtn = closeBtn

-- Separator under header
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, 0, 0, 1)
sep.Position = UDim2.new(0, 0, 0, 52)
sep.BackgroundColor3 = T.BORDER
sep.BorderSizePixel = 0
sep.Parent = mainFrame

-- ─────────────────────────────────────────
--  TOOLBAR ROW  (Dropdown · TextBox · X)
--  This is the shared input row used by all viewer modes
-- ─────────────────────────────────────────
local toolbar = Instance.new("Frame")
toolbar.Name = "Toolbar"
toolbar.Size = UDim2.new(1, 0, 0, 42)
toolbar.Position = UDim2.new(0, 0, 0, 53)
toolbar.BackgroundTransparency = 1
toolbar.Parent = mainFrame
GUI.toolbar = toolbar

-- VCP Button (only visible in Game mode)
local vcpBtn = btn(toolbar, {
    Text = "VCP",
    Size = UDim2.new(0, 46, 0, 30),
    Position = UDim2.new(0, 8, 0.5, -15),
    BackgroundColor3 = T.BTN_BLUE,
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    Visible = false,
})
addButtonFX(vcpBtn, T.BTN_BLUE, T.BTN_BLUE_H, Color3.fromRGB(0,100,180))
GUI.vcpBtn = vcpBtn

-- Viewer Dropdown button
local viewerDropBtn = btn(toolbar, {
    Text = "Viewer  ▾",
    Size = UDim2.new(0, 110, 0, 30),
    Position = UDim2.new(0, 8, 0.5, -15),
    BackgroundColor3 = T.SURFACE2,
})
addButtonFX(viewerDropBtn, T.SURFACE2, T.BORDER, T.BORDER2)
stroke(viewerDropBtn, 1, T.BORDER)
GUI.viewerDropBtn = viewerDropBtn

-- Search TextBox
local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Size = UDim2.new(1, -170, 0, 30)
searchBox.Position = UDim2.new(0, 126, 0.5, -15)
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
stroke(searchBox, 1, T.BORDER)
local sbPad = Instance.new("UIPadding")
sbPad.PaddingLeft = UDim.new(0,8)
sbPad.PaddingRight = UDim.new(0,8)
sbPad.Parent = searchBox
searchBox.Focused:Connect(function()
    TweenService:Create(searchBox:FindFirstChildWhichIsA("UIStroke"), TweenInfo.new(0.15), {Color=T.BORDER2}):Play()
end)
searchBox.FocusLost:Connect(function()
    TweenService:Create(searchBox:FindFirstChildWhichIsA("UIStroke"), TweenInfo.new(0.15), {Color=T.BORDER}):Play()
end)
GUI.searchBox = searchBox

-- Search / Go button
local goBtn = btn(toolbar, {
    Text = "→",
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -38, 0.5, -15),
    BackgroundColor3 = T.SURFACE2,
    TextColor3 = T.TEXT2,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
})
addButtonFX(goBtn, T.SURFACE2, T.BORDER, T.BORDER2)
stroke(goBtn, 1, T.BORDER)
GUI.goBtn = goBtn

-- Second separator
local sep2 = Instance.new("Frame")
sep2.Size = UDim2.new(1, 0, 0, 1)
sep2.Position = UDim2.new(0, 0, 0, 95)
sep2.BackgroundColor3 = T.BORDER
sep2.BorderSizePixel = 0
sep2.Parent = mainFrame

-- ─────────────────────────────────────────
--  CONTENT AREA  (scrolling)
-- ─────────────────────────────────────────
local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Name = "Content"
contentScroll.Size = UDim2.new(1, 0, 1, -96)
contentScroll.Position = UDim2.new(0, 0, 0, 96)
contentScroll.BackgroundTransparency = 1
contentScroll.ScrollBarThickness = 3
contentScroll.ScrollBarImageColor3 = T.BORDER2
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.BorderSizePixel = 0
contentScroll.Parent = mainFrame
GUI.contentScroll = contentScroll

-- ─────────────────────────────────────────
--  DRAG LOGIC  (mouse + touch)
-- ─────────────────────────────────────────
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
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ─────────────────────────────────────────
--  VIEWER DROPDOWN  (mini GUI)
-- ─────────────────────────────────────────
local VIEWER_MODES = {"Catalog", "Game", "Player | Community"}
local currentMode = "Catalog"
GUI.currentMode = currentMode

local viewerMenu = Instance.new("Frame")
viewerMenu.Name = "ViewerMenu"
viewerMenu.Size = UDim2.new(0, 160, 0, #VIEWER_MODES * 34 + 8)
viewerMenu.BackgroundColor3 = T.SURFACE2
viewerMenu.BorderSizePixel = 0
viewerMenu.Visible = false
viewerMenu.ZIndex = 20
viewerMenu.Parent = screenGui
corner(viewerMenu, 8)
stroke(viewerMenu, 1, T.BORDER)
GUI.viewerMenu = viewerMenu

local vmLayout = Instance.new("UIListLayout")
vmLayout.Padding = UDim.new(0, 2)
vmLayout.Parent = viewerMenu
local vmPad = Instance.new("UIPadding")
vmPad.PaddingTop = UDim.new(0,4)
vmPad.PaddingBottom = UDim.new(0,4)
vmPad.PaddingLeft = UDim.new(0,4)
vmPad.PaddingRight = UDim.new(0,4)
vmPad.Parent = viewerMenu

local vmCallbacks = {}  -- {modeName = function}

for _, modeName in ipairs(VIEWER_MODES) do
    local item = btn(viewerMenu, {
        Text = modeName,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = T.SURFACE2,
        TextColor3 = T.TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 21,
    })
    local ip = Instance.new("UIPadding")
    ip.PaddingLeft = UDim.new(0,10)
    ip.Parent = item
    addButtonFX(item, T.SURFACE2, T.BORDER, T.SURFACE)
    item.MouseButton1Click:Connect(function()
        currentMode = modeName
        GUI.currentMode = modeName
        viewerDropBtn.Text = modeName .. "  ▾"
        viewerMenu.Visible = false
        -- show VCP only for Game
        vcpBtn.Visible = (modeName == "Game")
        if modeName == "Game" then
            viewerDropBtn.Position = UDim2.new(0, 62, 0.5, -15)
            viewerDropBtn.Size = UDim2.new(0, 90, 0, 30)
        else
            viewerDropBtn.Position = UDim2.new(0, 8, 0.5, -15)
            viewerDropBtn.Size = UDim2.new(0, 110, 0, 30)
        end
        -- recalc searchbox width
        local leftEdge = (modeName == "Game") and (62+90+8) or (8+110+8)
        searchBox.Position = UDim2.new(0, leftEdge, 0.5, -15)
        searchBox.Size = UDim2.new(1, -(leftEdge + 46), 0, 30)
        if vmCallbacks[modeName] then vmCallbacks[modeName]() end
    end)
end

GUI.setModeCallback = function(modeName, cb)
    vmCallbacks[modeName] = cb
end

-- toggle dropdown
local function positionViewerMenu()
    local abs = viewerDropBtn.AbsolutePosition
    local sz  = viewerDropBtn.AbsoluteSize
    viewerMenu.Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 4)
end
viewerDropBtn.MouseButton1Click:Connect(function()
    positionViewerMenu()
    viewerMenu.Visible = not viewerMenu.Visible
end)

-- ─────────────────────────────────────────
--  CLOSE MINI GUI ON OUTSIDE CLICK
-- ─────────────────────────────────────────
-- Registry of active mini guis that close on outside click
GUI.miniGuis = {}

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then return end

    -- close viewer dropdown
    if viewerMenu.Visible then
        local pos = input.Position
        local abs = viewerMenu.AbsolutePosition
        local sz  = viewerMenu.AbsoluteSize
        if pos.X < abs.X or pos.X > abs.X+sz.X or pos.Y < abs.Y or pos.Y > abs.Y+sz.Y then
            viewerMenu.Visible = false
        end
    end

    -- close registered mini guis
    for i = #GUI.miniGuis, 1, -1 do
        local mg = GUI.miniGuis[i]
        if mg and mg.Parent then
            local pos = input.Position
            local abs = mg.AbsolutePosition
            local sz  = mg.AbsoluteSize
            if pos.X < abs.X or pos.X > abs.X+sz.X or pos.Y < abs.Y or pos.Y > abs.Y+sz.Y then
                mg.Visible = false
            end
        else
            table.remove(GUI.miniGuis, i)
        end
    end
end)

-- ─────────────────────────────────────────
--  MINI GUI FACTORY
--  items = { {text=string, icon=string, callback=function} }
-- ─────────────────────────────────────────
function GUI.createMiniGui(items, anchorAbsPos)
    -- reuse or create
    local mg = Instance.new("Frame")
    mg.Size = UDim2.new(0, 200, 0, #items * 36 + 8)
    mg.BackgroundColor3 = T.SURFACE2
    mg.BorderSizePixel = 0
    mg.ZIndex = 50
    mg.Parent = screenGui
    corner(mg, 8)
    stroke(mg, 1, T.BORDER)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,2)
    layout.Parent = mg
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0,4)
    pad.PaddingBottom = UDim.new(0,4)
    pad.PaddingLeft   = UDim.new(0,4)
    pad.PaddingRight  = UDim.new(0,4)
    pad.Parent = mg

    for _, item in ipairs(items) do
        local row = btn(mg, {
            Text = (item.icon or "") .. "  " .. item.text,
            Size = UDim2.new(1, 0, 0, 30),
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

    -- position
    if anchorAbsPos then
        local x = anchorAbsPos.X
        local y = anchorAbsPos.Y + 24
        local screenSz = screenGui.AbsoluteSize
        if x + 200 > screenSz.X then x = screenSz.X - 204 end
        if y + mg.AbsoluteSize.Y > screenSz.Y then y = anchorAbsPos.Y - mg.AbsoluteSize.Y - 4 end
        mg.Position = UDim2.new(0, x, 0, y)
    end

    table.insert(GUI.miniGuis, mg)
    return mg
end

-- ─────────────────────────────────────────
--  SIDE GUI FACTORY
-- ─────────────────────────────────────────
GUI.activeSideGui = nil

function GUI.openSideGui(title, buildFn)
    if GUI.activeSideGui then
        GUI.activeSideGui:Destroy()
        GUI.activeSideGui = nil
    end

    local SIDE_W = 260
    local mainAbs = mainFrame.AbsolutePosition
    local mainSz  = mainFrame.AbsoluteSize

    local sg = Instance.new("Frame")
    sg.Name = "SideGui"
    sg.Size = UDim2.new(0, SIDE_W, 0, mainSz.Y)
    sg.Position = UDim2.new(0, mainAbs.X - SIDE_W - 10, 0, mainAbs.Y)
    sg.BackgroundColor3 = T.BG
    sg.BorderSizePixel = 0
    sg.ClipsDescendants = true
    sg.Parent = screenGui
    corner(sg, 10)
    stroke(sg, 1, T.BORDER)
    GUI.activeSideGui = sg

    -- header
    local sgHeader = Instance.new("Frame")
    sgHeader.Size = UDim2.new(1,0,0,42)
    sgHeader.BackgroundColor3 = T.SURFACE
    sgHeader.BorderSizePixel = 0
    sgHeader.Parent = sg
    corner(sgHeader, 10)
    local shFix = Instance.new("Frame")
    shFix.Size = UDim2.new(1,0,0,10)
    shFix.Position = UDim2.new(0,0,1,-10)
    shFix.BackgroundColor3 = T.SURFACE
    shFix.BorderSizePixel = 0
    shFix.Parent = sgHeader

    label(sgHeader, {
        Text = title,
        Size = UDim2.new(1,-40,1,0),
        Position = UDim2.new(0,12,0,0),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
    })

    local sgClose = btn(sgHeader, {
        Text = "✕",
        Size = UDim2.new(0,26,0,26),
        Position = UDim2.new(1,-32,0.5,-13),
        BackgroundColor3 = T.SURFACE2,
        TextColor3 = T.TEXT2,
        TextSize = 11,
    })
    addButtonFX(sgClose, T.SURFACE2, T.BORDER, T.BORDER2)
    sgClose.MouseButton1Click:Connect(function()
        sg:Destroy()
        GUI.activeSideGui = nil
    end)

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1,0,0,1)
    sep.Position = UDim2.new(0,0,0,42)
    sep.BackgroundColor3 = T.BORDER
    sep.BorderSizePixel = 0
    sep.Parent = sg

    -- scrolling content
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

    -- slide in
    sg.Position = UDim2.new(0, mainAbs.X - 10, 0, mainAbs.Y)
    TweenService:Create(sg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, mainAbs.X - SIDE_W - 10, 0, mainAbs.Y)}):Play()

    return sg, sgScroll
end

-- ─────────────────────────────────────────
--  CONTENT HELPERS  (used by viewer modules)
-- ─────────────────────────────────────────

-- Clear content area and reset height
function GUI.clearContent()
    for _, c in ipairs(contentScroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
            c:Destroy()
        end
    end
    contentScroll.CanvasSize = UDim2.new(0,0,0,0)
end

-- Set main frame height with tween
function GUI.setMainHeight(h)
    TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        {Size = UDim2.new(0, MAIN_W, 0, h)}):Play()
end

-- Show loading state
function GUI.showLoading()
    GUI.clearContent()
    GUI.setMainHeight(150)
    local l = label(contentScroll, {
        Text = "Loading...",
        Size = UDim2.new(1,0,0,50),
        Position = UDim2.new(0,0,0,10),
        TextColor3 = T.TEXT3,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextSize = 13,
    })
end

-- Show error state
function GUI.showError(msg)
    GUI.clearContent()
    GUI.setMainHeight(130)
    local ic = label(contentScroll, {
        Text = "⚠",
        Size = UDim2.new(1,0,0,28),
        Position = UDim2.new(0,0,0,12),
        TextColor3 = T.WARNING,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextSize = 22,
    })
    local l = label(contentScroll, {
        Text = msg or "Something went wrong.",
        Size = UDim2.new(1,-32,0,40),
        Position = UDim2.new(0,16,0,44),
        TextColor3 = T.TEXT2,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextWrapped = true,
        TextSize = 12,
    })
end

-- Icon image (loads async)
function GUI.makeIcon(parent, size, pos, imageId)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = pos
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

-- Copy icon button
function GUI.makeCopyIcon(parent, pos, menuItems)
    local cb = btn(parent, {
        Text = "⧉",
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = T.TEXT3,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
    })
    cb.Position = pos
    cb.MouseEnter:Connect(function() cb.TextColor3 = T.TEXT end)
    cb.MouseLeave:Connect(function() cb.TextColor3 = T.TEXT3 end)
    cb.MouseButton1Click:Connect(function()
        local mg = GUI.createMiniGui(menuItems, cb.AbsolutePosition)
        mg.Visible = true
    end)
    return cb
end

-- Row label pair  (key : value)
function GUI.makeRow(parent, y, key, value, copyMenuItems)
    local keyL = label(parent, {
        Text = key,
        Size = UDim2.new(0, 90, 0, 22),
        Position = UDim2.new(0, 0, 0, y),
        TextColor3 = T.TEXT3,
        TextSize = 12,
    })

    local valL = label(parent, {
        Text = value or "—",
        Size = UDim2.new(1, -(copyMenuItems and 120 or 100), 0, 22),
        Position = UDim2.new(0, 94, 0, y),
        TextColor3 = T.TEXT,
        TextSize = 12,
        TextWrapped = false,
        ClipsDescendants = false,
    })

    local copyBtn
    if copyMenuItems then
        copyBtn = GUI.makeCopyIcon(parent,
            UDim2.new(1, -22, 0, y + 1),
            copyMenuItems)
    end
    return keyL, valL, copyBtn
end

-- ─────────────────────────────────────────
--  CLOSE BUTTON
-- ─────────────────────────────────────────
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ─────────────────────────────────────────
--  OPEN ANIMATION
-- ─────────────────────────────────────────
mainFrame.BackgroundTransparency = 1
TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {BackgroundTransparency = 0}):Play()

return GUI

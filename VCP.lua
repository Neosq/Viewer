-- ╔══════════════════════════════════════════════════════════════════╗
-- ║               VCP VIEWER  —  VCP.lua (Main Wiring)              ║
-- ║  Expects in env: GUI, CatalogViewer, GameViewer, PCViewer       ║
-- ║  Loaded by Loader.lua via setfenv                               ║
-- ╚══════════════════════════════════════════════════════════════════╝

-- Cross-module: "View Profile" in Game/Catalog opens PC viewer
GUI.onViewCreator = function(creatorType, creatorId)
    if not creatorId then return end
    GUI.currentMode = "Player | Community"
    GUI.viewerDropBtn.Text = "Player | Community  ▾"
    GUI.vcpBtn.Visible = false
    GUI.viewerDropBtn.Position = UDim2.new(0, 8, 0.5, -15)
    GUI.viewerDropBtn.Size = UDim2.new(0, 140, 0, 30)
    GUI.searchBox.Position = UDim2.new(0, 156, 0.5, -15)
    GUI.searchBox.Size = UDim2.new(1, -202, 0, 30)
    PCViewer.init(GUI)
    if creatorType == "Group" or creatorType == "group" then
        PCViewer.loadGroup(GUI, tostring(creatorId))
    else
        PCViewer.loadUser(GUI, tostring(creatorId))
    end
end

-- Mode switch callbacks (triggered by viewer dropdown)
GUI.setModeCallback("Catalog", function()
    CatalogViewer.init(GUI)
end)

GUI.setModeCallback("Game", function()
    GameViewer.init(GUI)
end)

GUI.setModeCallback("Player | Community", function()
    PCViewer.init(GUI)
end)

-- Enter key in search box fires the go button
GUI.searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        GUI.goBtn.MouseButton1Click:Fire()
    end
end)

-- Default mode on open: Catalog
CatalogViewer.init(GUI)
GUI.viewerDropBtn.Text = "Catalog  ▾"
GUI.showError("Enter an asset URL or ID to get started.")

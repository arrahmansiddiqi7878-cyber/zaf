local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "BreakDoor Utility Hub",
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "by arrahmansiddiqi7878-cyber",
   ConfigurationSaving = { Enabled = false }
})

-- Tabs Setup
local CombatTab = Window:CreateTab("Combat & Utility", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local VisualsTab = Window:CreateTab("Visuals (ESP)", 4483362458)
local AutomationTab = Window:CreateTab("Automation", 4483362458)

---------------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------------
local function getPromptPos(prompt)
    local parent = prompt.Parent
    if not parent then return nil end
    
    if parent:IsA("BasePart") then
        return parent.Position
    elseif parent:IsA("Model") then
        return parent:GetPivot().Position
    elseif parent:IsA("Attachment") then
        return parent.WorldPosition
    else
        local part = parent:FindFirstChildWhichIsA("BasePart", true)
        return part and part.Position or nil
    end
end

local function interactPrompt(prompt)
    if prompt and prompt.Enabled and fireproximityprompt then
        pcall(function()
            prompt.HoldDuration = 0
            fireproximityprompt(prompt)
        end)
    end
end

local function forceClickGuiButton(button)
    pcall(function()
        if firesignal then
            firesignal(button.MouseButton1Click)
            firesignal(button.Activated)
            firesignal(button.InputBegan)
        end
        if getconnections then
            for _, conn in pairs(getconnections(button.MouseButton1Click)) do conn:Fire() end
            for _, conn in pairs(getconnections(button.Activated)) do conn:Fire() end
            for _, conn in pairs(getconnections(button.InputBegan)) do conn:Fire() end
        end
    end)
end

---------------------------------------------------------------------
-- 1. COMBAT & UTILITY (Noclip, Attack Aura, & God Mode)
---------------------------------------------------------------------
local noclipEnabled = false
local attackAuraEnabled = false
local attackRange = 15
local godModeEnabled = false
local godConnection = nil

-- Noclip Logic
game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled then
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

CombatTab:CreateToggle({
   Name = "Noclip (Walk Through Walls)",
   CurrentValue = false,
   Flag = "NoclipFlag",
   Callback = function(Value)
       noclipEnabled = Value
   end,
})

-- God Mode Logic
CombatTab:CreateToggle({
   Name = "God Mode (Local Protection)",
   CurrentValue = false,
   Flag = "GodModeFlag",
   Callback = function(Value)
       godModeEnabled = Value
       local char = game.Players.LocalPlayer.Character
       local hum = char and char:FindFirstChildOfClass("Humanoid")

       if godModeEnabled then
           if hum then
               hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
           end

           godConnection = game:GetService("RunService").RenderStepped:Connect(function()
               if godModeEnabled then
                   pcall(function()
                       local c = game.Players.LocalPlayer.Character
                       local h = c and c:FindFirstChildOfClass("Humanoid")
                       if h then
                           h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                           if h.Health < h.MaxHealth then
                               h.Health = h.MaxHealth
                           end
                       end
                   end)
               end
           end)
       else
           if godConnection then
               godConnection:Disconnect()
               godConnection = nil
           end
           if hum then
               hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
           end
       end
   end,
})

-- Attack Aura Logic
task.spawn(function()
    while true do
        if attackAuraEnabled then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local tool = char and char:FindFirstChildOfClass("Tool")

                if root and tool then
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and player.Character then
                            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                            local targetHum = player.Character:FindFirstChild("Humanoid")

                            if targetRoot and targetHum and targetHum.Health > 0 then
                                local distance = (root.Position - targetRoot.Position).Magnitude
                                if distance <= attackRange then
                                    tool:Activate()
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.15)
    end
end)

CombatTab:CreateToggle({
   Name = "Demon Attack Aura",
   CurrentValue = false,
   Flag = "AttackAuraFlag",
   Callback = function(Value)
       attackAuraEnabled = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Aura Range (Studs)",
   Range = {5, 30},
   Increment = 1,
   Suffix = "studs",
   CurrentValue = 15,
   Flag = "AuraRangeFlag",
   Callback = function(Value)
       attackRange = Value
   end,
})

---------------------------------------------------------------------
-- 2. MOVEMENT SETTINGS (Persistent Speed Loop)
---------------------------------------------------------------------
local targetWalkSpeed = 16
local speedLoopEnabled = false

game:GetService("RunService").RenderStepped:Connect(function()
    if speedLoopEnabled then
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = targetWalkSpeed
        end
    end
end)

MovementTab:CreateToggle({
   Name = "Enable Speed Loop (Anti-Slowdown)",
   CurrentValue = false,
   Flag = "SpeedLoopToggle",
   Callback = function(Value)
       speedLoopEnabled = Value
   end,
})

MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 120},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedFlag",
   Callback = function(Value)
       targetWalkSpeed = Value
   end,
})

---------------------------------------------------------------------
-- 3. VISUAL HIGHLIGHTS
---------------------------------------------------------------------
local espHighlights = {}

VisualsTab:CreateToggle({
   Name = "Demon & Player Highlights",
   CurrentValue = false,
   Flag = "ESPFlag",
   Callback = function(Enabled)
       if Enabled then
           for _, player in pairs(game.Players:GetPlayers()) do
               if player ~= game.Players.LocalPlayer and player.Character then
                   if not player.Character:FindFirstChild("ESPHighlight") then
                       local highlight = Instance.new("Highlight")
                       highlight.Name = "ESPHighlight"
                       highlight.FillColor = player:FindFirstChild("IsDemon") and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                       highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                       highlight.FillTransparency = 0.5
                       highlight.Parent = player.Character
                       table.insert(espHighlights, highlight)
                   end
               end
           end
       else
           for _, highlight in pairs(espHighlights) do
               if highlight then highlight:Destroy() end
           end
           table.clear(espHighlights)
       end
   end,
})

---------------------------------------------------------------------
-- 4. AUTOMATION
---------------------------------------------------------------------
local autoCollectAura = false
local autoRepair = false
local savedBaseCFrame = nil
local collectAuraRange = 50

AutomationTab:CreateButton({
   Name = "Set Current Position as Base",
   Callback = function()
       local char = game.Players.LocalPlayer.Character
       local root = char and char:FindFirstChild("HumanoidRootPart")
       if root then
           savedBaseCFrame = root.CFrame
           Rayfield:Notify({
               Title = "Base Saved",
               Content = "Your current position has been saved as Base!",
               Duration = 3,
               Image = 4483362458,
           })
       end
   end,
})

AutomationTab:CreateButton({
   Name = "Teleport to Base",
   Callback = function()
       local char = game.Players.LocalPlayer.Character
       local root = char and char:FindFirstChild("HumanoidRootPart")
       
       if savedBaseCFrame and root then
           root.CFrame = savedBaseCFrame + Vector3.new(0, 3, 0)
       else
           local spawnPoint = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Base")
           if spawnPoint and root then
               root.CFrame = spawnPoint.CFrame + Vector3.new(0, 5, 0)
           else
               Rayfield:Notify({
                   Title = "Teleport Failed",
                   Content = "Please click 'Set Current Position as Base' first!",
                   Duration = 3,
                   Image = 4483362458,
               })
           end
       end
   end,
})

-- Smart Auto-Repair
AutomationTab:CreateToggle({
   Name = "Auto-Repair (Screen Wrench & Doors)",
   CurrentValue = false,
   Flag = "AutoRepairFlag",
   Callback = function(Value)
       autoRepair = Value
       if autoRepair then
           task.spawn(function()
               while autoRepair do
                   pcall(function()
                       local pGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                       if pGui then
                           for _, btn in pairs(pGui:GetDescendants()) do
                               if (btn:IsA("ImageButton") or btn:IsA("TextButton") or btn:IsA("ImageLabel")) and btn.AbsoluteSize.X > 0 and btn.AbsoluteSize.Y > 0 then
                                   local name = btn.Name:lower()
                                   local parentName = btn.Parent and btn.Parent.Name:lower() or ""
                                   
                                   if name:find("repair") or name:find("wrench") or parentName:find("repair") or parentName:find("wrench") or name:find("fix") then
                                       local targetBtn = btn:IsA("ImageLabel") and btn.Parent or btn
                                       if targetBtn:IsA("GuiButton") then
                                           forceClickGuiButton(targetBtn)
                                       end
                                   end
                               end
                           end
                       end

                       local char = game.Players.LocalPlayer.Character
                       local root = char and char:FindFirstChild("HumanoidRootPart")
                       if root then
                           for _, prompt in pairs(workspace:GetDescendants()) do
                               if prompt:IsA("ProximityPrompt") then
                                   local actionText = prompt.ActionText:lower()
                                   local objectText = prompt.ObjectText:lower()
                                   
                                   local isUpgrade = actionText:find("upgrade") or objectText:find("upgrade") or actionText:find("level")
                                   local isRepair = actionText:find("repair") or actionText:find("fix") or actionText:find("rebuild") or actionText:find("board") or actionText:find("fortify")
                                   
                                   if isRepair and not isUpgrade then
                                       local pos = getPromptPos(prompt)
                                       if pos and (root.Position - pos).Magnitude <= (prompt.MaxActivationDistance + 10) then
                                           interactPrompt(prompt)
                                       end
                                   end
                               end
                           end
                       end
                   end)
                   task.wait(0.15)
               end
           end)
       end
   end,
})

-- Auto-Collect Box Aura
AutomationTab:CreateToggle({
   Name = "Auto-Collect Box Aura",
   CurrentValue = false,
   Flag = "AutoCollectAuraFlag",
   Callback = function(Value)
       autoCollectAura = Value
       if autoCollectAura then
           task.spawn(function()
               while autoCollectAura do
                   pcall(function()
                       local char = game.Players.LocalPlayer.Character
                       local root = char and char:FindFirstChild("HumanoidRootPart")
                       
                       if root then
                           for _, prompt in pairs(workspace:GetDescendants()) do
                               if prompt:IsA("ProximityPrompt") then
                                   local actionText = prompt.ActionText:lower()
                                   local objectText = prompt.ObjectText:lower()
                                   local parentName = prompt.Parent and prompt.Parent.Name:lower() or ""
                                   
                                   local isUpgrade = actionText:find("upgrade") or objectText:find("upgrade") or actionText:find("level")
                                   local isBoxOrItem = actionText:find("collect") or actionText:find("take") or actionText:find("grab") or actionText:find("pickup") or actionText:find("open") or objectText:find("box") or objectText:find("crate") or objectText:find("supply") or parentName:find("box") or parentName:find("crate") or parentName:find("supply")
                                   
                                   if isBoxOrItem and not isUpgrade then
                                       local pos = getPromptPos(prompt)
                                       if pos and (root.Position - pos).Magnitude <= collectAuraRange then
                                           interactPrompt(prompt)
                                       end
                                   end
                               end
                           end

                           for _, obj in pairs(workspace:GetDescendants()) do
                               if obj:IsA("BasePart") or obj:IsA("Model") then
                                   local name = obj.Name:lower()
                                   if name:find("box") or name:find("crate") or name:find("supply") or name:find("drop") then
                                       local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                                       if part and (root.Position - part.Position).Magnitude <= collectAuraRange then
                                           if firetouchinterest then
                                               firetouchinterest(root, part, 0)
                                               firetouchinterest(root, part, 1)
                                           end
                                       end
                                   end
                               end
                           end
                       end
                   end)
                   task.wait(0.2)
               end
           end)
       end
   end,
})

AutomationTab:CreateSlider({
   Name = "Box Aura Range (Studs)",
   Range = {10, 100},
   Increment = 5,
   Suffix = "studs",
   CurrentValue = 50,
   Flag = "BoxAuraRangeFlag",
   Callback = function(Value)
       collectAuraRange = Value
   end,
})

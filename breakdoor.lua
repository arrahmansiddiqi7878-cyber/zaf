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
-- 1. COMBAT & UTILITY (Noclip & Attack Aura)
---------------------------------------------------------------------
local noclipEnabled = false
local attackAuraEnabled = false
local attackRange = 15

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

-- Attack Aura Logic
task.spawn(function()
    while true do
        if attackAuraEnabled then
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
-- 2. MOVEMENT SETTINGS
---------------------------------------------------------------------
MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 120},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedFlag",
   Callback = function(Value)
       local char = game.Players.LocalPlayer.Character
       if char and char:FindFirstChild("Humanoid") then
           char.Humanoid.WalkSpeed = Value
       end
   end,
})

---------------------------------------------------------------------
-- 3. VISUAL HIGHLIGHTS (Demon & Player ESP)
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
-- 4. AUTOMATION (Auto-Collect, Auto-Repair, & Base Teleport)
---------------------------------------------------------------------
local autoCollect = false
local autoRepair = false
local savedBaseCFrame = nil

-- Set Base Position Button
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

-- Teleport to Base Button
AutomationTab:CreateButton({
   Name = "Teleport to Base",
   Callback = function()
       local char = game.Players.LocalPlayer.Character
       local root = char and char:FindFirstChild("HumanoidRootPart")
       
       if savedBaseCFrame and root then
           root.CFrame = savedBaseCFrame + Vector3.new(0, 3, 0)
       else
           -- Fallback: Searches for workspace Base/Spawn objects if no custom position was set
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

-- Auto-Repair Toggle
AutomationTab:CreateToggle({
   Name = "Auto-Repair (Doors/Structures)",
   CurrentValue = false,
   Flag = "AutoRepairFlag",
   Callback = function(Value)
       autoRepair = Value
       if autoRepair then
           task.spawn(function()
               while autoRepair do
                   local char = game.Players.LocalPlayer.Character
                   local root = char and char:FindFirstChild("HumanoidRootPart")
                   
                   if root then
                       for _, prompt in pairs(workspace:GetDescendants()) do
                           if prompt:IsA("ProximityPrompt") and prompt.Parent then
                               local name = prompt.Parent.Name:lower()
                               local action = prompt.ActionText:lower()
                               
                               -- Target repair prompts or door interactions
                               if name:find("repair") or name:find("door") or action:find("repair") or action:find("fix") then
                                   local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                                   if part and (root.Position - part.Position).Magnitude <= prompt.MaxActivationDistance then
                                       fireproximityprompt(prompt)
                                   end
                               end
                           end
                       end
                   end
                   task.wait(0.3)
               end
           end)
       end
   end,
})

-- Auto-Collect Proximity Prompts
AutomationTab:CreateToggle({
   Name = "Auto-Collect Proximity Prompts",
   CurrentValue = false,
   Flag = "AutoCollectFlag",
   Callback = function(Value)
       autoCollect = Value
       if autoCollect then
           task.spawn(function()
               while autoCollect do
                   local char = game.Players.LocalPlayer.Character
                   local root = char and char:FindFirstChild("HumanoidRootPart")
                   if root then
                       for _, prompt in pairs(workspace:GetDescendants()) do
                           if prompt:IsA("ProximityPrompt") and prompt.Parent then
                               local part = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                               if part then
                                   if (root.Position - part.Position).Magnitude <= 15 then
                                       fireproximityprompt(prompt)
                                   end
                               end
                           end
                       end
                   end
                   task.wait(0.5)
               end
           end)
       end
   end,
})

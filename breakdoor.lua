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
-- SHARED VARIABLES & HELPER FUNCTIONS
---------------------------------------------------------------------
local savedBaseCFrame = nil

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
-- 1. COMBAT & UTILITY
---------------------------------------------------------------------
local noclipEnabled = false
local attackAuraEnabled = false
local attackRange = 50
local targetMode = "Other Players (Demon Mode)"
local autoRecallEnabled = false
local recallCooldown = false

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

---------------------------------------------------------------------
-- ROLE-AWARE EMERGENCY RECALL SYSTEM
---------------------------------------------------------------------
local function getPlayerRole()
    local player = game.Players.LocalPlayer
    local char = player.Character

    -- 1. Check Team Name
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("demon") then return "Demon" end
        if teamName:find("human") then return "Human" end
    end

    -- 2. Check Player/Character Attributes
    local raceAttr = player:GetAttribute("Race") or (char and char:GetAttribute("Race"))
    if raceAttr then
        if tostring(raceAttr):lower():find("demon") then return "Demon" end
    end

    -- 3. Check for StringValue/Folder named "Race" or "Role"
    local raceVal = player:FindFirstChild("Race") or (char and char:FindFirstChild("Race"))
    if raceVal and raceVal:IsA("StringValue") then
        if raceVal.Value:lower():find("demon") then return "Demon" end
    end

    -- Default fallback if no tag found
    return "Human"
end

CombatTab:CreateToggle({
   Name = "Emergency Base Teleport (Role-Based)",
   CurrentValue = false,
   Flag = "GodRecallFlag",
   Callback = function(Value)
       autoRecallEnabled = Value
   end,
})

-- RenderStepped check loop
game:GetService("RunService").RenderStepped:Connect(function()
    if autoRecallEnabled and not recallCooldown then
        pcall(function()
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if hum and root and hum.Health > 0 then
                local hpPercent = (hum.Health / hum.MaxHealth) * 100
                
                -- Determine Role and Dynamic Threshold (50% Human / 25% Demon)
                local currentRole = getPlayerRole()
                local requiredThreshold = (currentRole == "Demon") and 25 or 50
                
                if hpPercent <= requiredThreshold then
                    recallCooldown = true
                    
                    -- Determine teleport destination
                    local targetCFrame = nil
                    if savedBaseCFrame then
                        targetCFrame = savedBaseCFrame + Vector3.new(0, 3, 0)
                    else
                        local spawnPoint = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Base")
                        if spawnPoint then
                            targetCFrame = spawnPoint.CFrame + Vector3.new(0, 5, 0)
                        end
                    end

                    -- Execute Teleport & Reset Physics Momentum
                    if targetCFrame then
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                        root.CFrame = targetCFrame
                        
                        Rayfield:Notify({
                            Title = "🚨 EMERGENCY RECALL",
                            Content = string.format("[%s] HP dropped below %d%%! Teleported to base.", currentRole, requiredThreshold),
                            Duration = 4,
                            Image = 4483362458,
                        })
                    end

                    -- 5-Second Cooldown Safety
                    task.delay(5, function()
                        recallCooldown = false
                    end)
                end
            end
        end)
    end
end)

CombatTab:CreateDropdown({
   Name = "Aura Target Mode",
   Options = {"Other Players (Demon Mode)", "NPC Monsters", "All (NPCs & Players)"},
   CurrentOption = {"Other Players (Demon Mode)"},
   MultipleOptions = false,
   Flag = "TargetModeDropdown",
   Callback = function(Option)
       targetMode = Option[1] or Option
   end,
})

CombatTab:CreateToggle({
   Name = "Enable Far-Range Attack Aura",
   CurrentValue = false,
   Flag = "AttackAuraFlag",
   Callback = function(Value)
       attackAuraEnabled = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Attack Range (Studs)",
   Range = {10, 100},
   Increment = 5,
   Suffix = "studs",
   CurrentValue = 50,
   Flag = "AuraRangeFlag",
   Callback = function(Value)
       attackRange = Value
   end,
})

task.spawn(function()
    while true do
        if attackAuraEnabled then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                local tool = char and char:FindFirstChildOfClass("Tool")
                if not tool then
                    local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
                    tool = backpack and backpack:FindFirstChildOfClass("Tool")
                    if tool and hum then
                        hum:EquipTool(tool)
                    end
                end

                if root and tool then
                    if targetMode == "Other Players (Demon Mode)" or targetMode == "All (NPCs & Players)" then
                        for _, player in pairs(game.Players:GetPlayers()) do
                            if player ~= game.Players.LocalPlayer and player.Character then
                                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                local targetHum = player.Character:FindFirstChildOfClass("Humanoid")

                                if targetRoot and targetHum and targetHum.Health > 0 then
                                    local dist = (root.Position - targetRoot.Position).Magnitude
                                    if dist <= attackRange then
                                        tool:Activate()
                                    end
                                end
                            end
                        end
                    end

                    if targetMode == "NPC Monsters" or targetMode == "All (NPCs & Players)" then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("Humanoid") and obj.Parent ~= char and obj.Health > 0 then
                                local targetChar = obj.Parent
                                local isPlayerChar = game.Players:GetPlayerFromCharacter(targetChar)
                                
                                if not isPlayerChar then
                                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChildWhichIsA("BasePart")
                                    if targetRoot then
                                        local dist = (root.Position - targetRoot.Position).Magnitude
                                        if dist <= attackRange then
                                            tool:Activate()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.08)
    end
end)

---------------------------------------------------------------------
-- 2. MOVEMENT SETTINGS
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
                       highlight.FillColor = Color3.fromRGB(255, 0, 0)
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
-- 4. AUTOMATION (Updated for Gifts & Present Boxes)
---------------------------------------------------------------------
local autoCollectAura = false
local autoRepair = false
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

-- Auto-Repair Door
AutomationTab:CreateToggle({
   Name = "Auto-Repair Door",
   CurrentValue = false,
   Flag = "AutoRepairFlag",
   Callback = function(Value)
       autoRepair = Value
       if autoRepair then
           task.spawn(function()
               while autoRepair do
                   pcall(function()
                       local char = game.Players.LocalPlayer.Character
                       local root = char and char:FindFirstChild("HumanoidRootPart")

                       if root then
                           for _, prompt in pairs(workspace:GetDescendants()) do
                               if prompt:IsA("ProximityPrompt") then
                                   local actText = prompt.ActionText:lower()
                                   local objText = prompt.ObjectText:lower()
                                   local parentName = prompt.Parent and prompt.Parent.Name:lower() or ""

                                   if actText:find("repair") or actText:find("fix") or objText:find("repair") or objText:find("door") or parentName:find("door") then
                                       local pos = getPromptPos(prompt)
                                       if pos and (root.Position - pos).Magnitude <= 30 then
                                           interactPrompt(prompt)
                                       end
                                   end
                               end
                           end
                       end

                       local pGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                       if pGui then
                           for _, element in pairs(pGui:GetDescendants()) do
                               if (element:IsA("ImageButton") or element:IsA("TextButton") or element:IsA("GuiButton")) and element.Visible then
                                   local name = element.Name:lower()
                                   local text = (element:IsA("TextButton") and element.Text:lower()) or ""

                                   if name:find("repair") or name:find("fix") or text:find("repair") or text:find("fix") then
                                       forceClickGuiButton(element)
                                   end
                               end
                           end
                       end
                   end)
                   task.wait(0.1)
               end
           end)
       end
   end,
})

-- Auto-Collect Gift / Present / Box Aura
AutomationTab:CreateToggle({
   Name = "Auto-Collect Gifts & Boxes",
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
                           -- 1. Proximity Prompts (Presents, Gifts, Boxes)
                           for _, prompt in pairs(workspace:GetDescendants()) do
                               if prompt:IsA("ProximityPrompt") then
                                   local actionText = prompt.ActionText:lower()
                                   local objectText = prompt.ObjectText:lower()
                                   local parentName = prompt.Parent and prompt.Parent.Name:lower() or ""
                                   
                                   -- Blacklist currency conversion/ATMs/upgrades
                                   local isBlacklisted = actionText:find("upgrade") or objectText:find("upgrade")
                                                      or actionText:find("convert") or objectText:find("convert")
                                                      or actionText:find("bank") or objectText:find("bank")
                                                      or actionText:find("atm") or parentName:find("atm")
                                                      or parentName:find("converter")

                                   if not isBlacklisted then
                                       local isTargetItem = actionText:find("open") or actionText:find("take") or actionText:find("collect") or actionText:find("claim")
                                                         or objectText:find("gift") or objectText:find("present") or objectText:find("box")
                                                         or parentName:find("gift") or parentName:find("present") or parentName:find("box") or parentName:find("crate")

                                       if isTargetItem then
                                           local pos = getPromptPos(prompt)
                                           if pos and (root.Position - pos).Magnitude <= collectAuraRange then
                                               interactPrompt(prompt)
                                           end
                                       end
                                   end
                               end
                           end

                           -- 2. Physical Parts / Touch Collections (Gifts & Boxes)
                           for _, part in pairs(workspace:GetDescendants()) do
                               if part:IsA("BasePart") then
                                   local pName = part.Name:lower()
                                   local parentName = part.Parent and part.Parent.Name:lower() or ""

                                   local isGiftOrBox = pName:find("gift") or pName:find("present") or pName:find("

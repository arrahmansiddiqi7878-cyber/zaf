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

local function clickGuiButton(button)
    if button and button.Visible then
        pcall(function()
            if firesignal then
                firesignal(button.MouseButton1Click)
                firesignal(button.Activated)
            elseif getconnections then
                for _, conn in pairs(getconnections(button.MouseButton1Click)) do
                    conn:Fire()
                end
                for _, conn in pairs(getconnections(button.Activated)) do
                    conn:Fire()
                end
            end
        end)
    end
end

---------------------------------------------------------------------
-- 1. COMBAT & UTILITY (Noclip & Attack Aura)
---------------------------------------------------------------------
local noclipEnabled = false
local attackAuraEnabled = false
local attackRange = 15

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
local maxInteractDistance = 20

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

-- Auto-Repair Toggle (Handles UI Button & Proximity Prompts)
AutomationTab:CreateToggle({
   Name = "Auto-Repair (UI Button & Doors)",
   CurrentValue = false,
   Flag = "AutoRepairFlag",
   Callback = function(Value)
       autoRepair = Value
       if autoRepair then
           task.spawn(function()
               while autoRepair do
                   pcall(function()
                       -- 1. Check PlayerGui for Screen Repair Buttons (Green Wrench)
                       local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                       if playerGui then
                           for _, element in pairs(playerGui:GetDescendants()) do
                               if (element:IsA("ImageButton") or element:IsA("TextButton")) and element.Visible then
                                   local name = element.Name:lower()
                                   if name:find("repair") or name:find("fix") or name:find("wrench") then
                                       clickGuiButton(element)
                                   end
                               end
                           end
                       end

                       -- 2. Check Workspace for 3D Proximity Repair Prompts
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
                                       if pos and (root.Position - pos).Magnitude <= (prompt.MaxActivationDistance + 5) then
                                           interactPrompt(prompt)
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

-- Auto-Collect Boxes & Items
AutomationTab:CreateToggle({
   Name = "Auto-Collect (Boxes & Cash)",
   CurrentValue = false,
   Flag = "AutoCollectFlag",
   Callback = function(Value)
       autoCollect = Value
       if autoCollect then
           task.spawn(function()
               while autoCollect do
                   pcall(function()
                       local char = game.Players.LocalPlayer.Character
                       local root = char and char:FindFirstChild("HumanoidRootPart")
                       
                       if root then
                           for _, prompt in pairs(workspace:GetDescendants()) do
                               if prompt:IsA("ProximityPrompt") then
                                   local actionText = prompt.ActionText:lower()
                                   local objectText = prompt.ObjectText:lower()
                                   
                                   local isUpgrade = actionText:find("upgrade") or objectText:find("upgrade") or actionText:find("level")
                                   local isCollect = actionText:find("collect") or actionText:find("take") or actionText:find("grab") or actionText:find("pickup") or actionText:find("open") or objectText:find("box") or objectText:find("crate") or objectText:find("gold") or objectText:find("cash") or objectText:find("money")
                                   
                                   if isCollect and not isUpgrade then
                                       local pos = getPromptPos(prompt)
                                       if pos and (root.Position - pos).Magnitude <= maxInteractDistance then
                                           interactPrompt(prompt)
                                       end
                                   end
                               end
                           end
                       end
                   end)
                   task.wait(0.3)
               end
           end)
       end
   end,
})

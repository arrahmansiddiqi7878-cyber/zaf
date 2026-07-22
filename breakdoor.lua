local R = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local W = R:CreateWindow({Name = "BreakDoor Utility Hub", LoadingTitle = "Loading...", ConfigurationSaving = {Enabled = false}})
local CT, MT, VT, AT = W:CreateTab("Combat & Utility", 4483362458), W:CreateTab("Movement", 4483362458), W:CreateTab("Visuals (ESP)", 4483362458), W:CreateTab("Automation", 4483362458)

local P, RS, WS, LP = game:GetService("Players"), game:GetService("RunService"), game:GetService("Workspace"), game:GetService("Players").LocalPlayer
local baseCFrame, noclip, aura, auraR, targetMode, autoRecall, speedLoop, speedVal, esp, autoRep, autoCol, colR = nil, false, false, 50, "Other Players (Demon Mode)", false, false, 16, false, false, 50

local function getPos(p) local par = p.Parent return not par and nil or (par:IsA("BasePart") and par.Position or (par:IsA("Model") and par:GetPivot().Position) or (par:IsA("Attachment") and par.WorldPosition) or (par:FindFirstChildWhichIsA("BasePart", true) and par:FindFirstChildWhichIsA("BasePart", true).Position)) end
local function intPrompt(p) if p and p.Enabled and fireproximityprompt then pcall(function() p.HoldDuration = 0 fireproximityprompt(p) end) end end

-- 1. Combat
RS.Stepped:Connect(function() if noclip and LP.Character then for _, v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end end)
CT:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) noclip = v end})

CT:CreateToggle({Name = "Emergency Base Teleport", CurrentValue = false, Callback = function(v) autoRecall = v end})
RS.Heartbeat:Connect(function()
    if autoRecall and LP.Character then
        pcall(function()
            local hum, root = LP.Character:FindFirstChildOfClass("Humanoid"), LP.Character:FindFirstChild("HumanoidRootPart")
            local isDemon = (LP.Team and LP.Team.Name:lower():find("demon")) or tostring(LP:GetAttribute("Race") or ""):lower():find("demon")
            if hum and root and hum.Health > 0 and (hum.Health/hum.MaxHealth)*100 <= (isDemon and 25 or 50) then
                root.CFrame = (baseCFrame or (WS:FindFirstChild("SpawnLocation") or WS:FindFirstChild("Base")).CFrame) + Vector3.new(0, 3, 0)
                R:Notify({Title = "EMERGENCY RECALL", Content = "HP low! Teleported to base.", Duration = 4})
                task.wait(5)
            end
        end)
    end
end)

CT:CreateDropdown({Name = "Aura Target Mode", Options = {"Other Players (Demon Mode)", "NPC Monsters", "All (NPCs & Players)"}, CurrentOption = {targetMode}, Callback = function(o) targetMode = type(o)=="table" and o[1] or o end})
CT:CreateToggle({Name = "Enable Attack Aura", CurrentValue = false, Callback = function(v) aura = v end})
CT:CreateSlider({Name = "Attack Range", Range = {10, 100}, Increment = 5, CurrentValue = 50, Callback = function(v) auraR = v end})

task.spawn(function()
    while true do
        if aura and LP.Character then
            pcall(function()
                local root, hum = LP.Character:FindFirstChild("HumanoidRootPart"), LP.Character:FindFirstChildOfClass("Humanoid")
                local tool = LP.Character:FindFirstChildOfClass("Tool") or (LP.Backpack and LP.Backpack:FindFirstChildOfClass("Tool"))
                if not LP.Character:FindFirstChildOfClass("Tool") and tool and hum then hum:EquipTool(tool) end
                if root and tool then
                    if targetMode ~= "NPC Monsters" then
                        for _, p in pairs(P:GetPlayers()) do
                            if p ~= LP and p.Character then
                                local tr, th = p.Character:FindFirstChild("HumanoidRootPart"), p.Character:FindFirstChildOfClass("Humanoid")
                                if tr and th and th.Health > 0 and (root.Position - tr.Position).Magnitude <= auraR then tool:Activate() end
                            end
                        end
                    end
                    if targetMode ~= "Other Players (Demon Mode)" then
                        for _, obj in pairs(WS:GetDescendants()) do
                            if obj:IsA("Humanoid") and obj.Parent ~= LP.Character and obj.Health > 0 and not P:GetPlayerFromCharacter(obj.Parent) then
                                local tr = obj.Parent:FindFirstChild("HumanoidRootPart") or obj.Parent:FindFirstChildWhichIsA("BasePart")
                                if tr and (root.Position - tr.Position).Magnitude <= auraR then tool:Activate() end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.08)
    end
end)

-- 2. Movement
RS.RenderStepped:Connect(function() if speedLoop and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speedVal end end)
MT:CreateToggle({Name = "Speed Loop", CurrentValue = false, Callback = function(v) speedLoop = v end})
MT:CreateSlider({Name = "WalkSpeed", Range = {16, 120}, Increment = 1, CurrentValue = 16, Callback = function(v) speedVal = v end})

-- 3. Visuals
local function applyESP(p)
    if p == LP then return end
    local function setup(c) if c and not c:FindFirstChild("ESP") then local h = Instance.new("Highlight", c) h.Name, h.FillColor, h.FillTransparency = "ESP", Color3.fromRGB(255, 0, 0), 0.5 end end
    if p.Character then setup(p.Character) end
    p.CharacterAdded:Connect(function(c) if esp then setup(c) end end)
end
for _, p in pairs(P:GetPlayers()) do applyESP(p) end
P.PlayerAdded:Connect(applyESP)

VT:CreateToggle({Name = "ESP Highlights", CurrentValue = false, Callback = function(v)
    esp = v
    for _, p in pairs(P:GetPlayers()) do
        if p ~= LP and p.Character then
            local hl = p.Character:FindFirstChild("ESP")
            if v and not hl then applyESP(p) elseif not v and hl then hl:Destroy() end
        end
    end
end})

-- 4. Automation
AT:CreateButton({Name = "Set Base", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then baseCFrame = LP.Character.HumanoidRootPart.CFrame R:Notify({Title = "Base Saved", Duration = 2}) end end})
AT:CreateButton({Name = "Teleport to Base", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame = (baseCFrame or WS.SpawnLocation.CFrame) + Vector3.new(0, 3, 0) end end})

AT:CreateToggle({Name = "Auto-Repair Door", CurrentValue = false, Callback = function(v) autoRep = v end})
AT:CreateToggle({Name = "Auto-Collect Gifts/Boxes", CurrentValue = false, Callback = function(v) autoCol = v end})
AT:CreateSlider({Name = "Collect Range", Range = {10, 100}, Increment = 5, CurrentValue = 50, Callback = function(v) colR = v end})

task.spawn(function()
    while true do
        if (autoRep or autoCol) and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local rootPos = LP.Character.HumanoidRootPart.Position
                for _, pr in pairs(WS:GetDescendants()) do
                    if pr:IsA("ProximityPrompt") then
                        local txt, ot = pr.ActionText:lower(), pr.ObjectText:lower()
                        local pos = getPos(pr)
                        if pos then
                            if autoRep and (txt:find("repair") or ot:find("repair")) and (rootPos - pos).Magnitude <= 30 then
                                intPrompt(pr)
                            elseif autoCol and not (txt:find("upgrade") or ot:find("upgrade") or txt:find("bank")) and (txt:find("open") or txt:find("collect") or ot:find("gift") or ot:find("box")) and (rootPos - pos).Magnitude <= colR then
                                intPrompt(pr)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.2)
    end
end)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Door Locked Hub", LoadingTitle = "Loading...", KeySystem = false})
local Tab = Win:CreateTab("Main", 4483362458)
getgenv().DS = {ESP = false, Breaker = false, Window = false, AutoLock = false, Fullbright = false}

local Plrs, Run, Ws = game:GetService("Players"), game:GetService("RunService"), game:GetService("Workspace")
local LP = Plrs.LocalPlayer

for _, v in ipairs({"ESP", "Breaker", "Window", "AutoLock", "Fullbright"}) do
   Tab:CreateToggle({Name = v, CurrentValue = false, Callback = function(val) getgenv().DS[v] = val end})
end

-- Fullbright & ESP Loop (using standard loops to ensure execution)
Run.RenderStepped:Connect(function()
   pcall(function()
      if getgenv().DS.Fullbright then
         game:GetService("Lighting").Brightness = 2
         game:GetService("Lighting").ClockTime = 14
         game:GetService("Lighting").GlobalShadows = false
      end
      
      if not getgenv().DS.ESP then return end
      for _, obj in pairs(Ws:GetDescendants()) do
         if obj:IsA("Model") and obj ~= LP.Character and not Plrs:GetPlayerFromCharacter(obj) then
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
            if hrp and not obj:FindFirstChild("H") then
               local hl = Instance.new("Highlight", obj)
               hl.Name = "H"
               hl.FillColor = Color3.fromRGB(0, 255, 0)
            end
         end
      end
   end)
end)

-- Automation Loop for Breaker and Window
task.spawn(function()
   while task.wait(0.5) do
      pcall(function()
         local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
         if not hrp then return end
         
         for _, obj in pairs(Ws:GetDescendants()) do
            local name = obj.Name:lower()
            -- Breaker Finder
            if getgenv().DS.Breaker and (name:find("breaker") or name:find("fuse") or name:find("switch")) then
               if obj:IsA("BasePart") then
                  firetouchinterest(hrp, obj, 0)
                  firetouchinterest(hrp, obj, 1)
               elseif obj:IsA("ClickDetector") then
                  fireclickdetector(obj)
               end
            end
            -- Window/Monster Finder
            if getgenv().DS.Window and (name:find("window") or name:find("monster") or name:find("entity")) then
               local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")) or (obj:IsA("BasePart") and obj)
               if targetPart and (targetPart.Position - hrp.Position).Magnitude < 25 and getgenv().DS.AutoLock then
                  for _, door in pairs(Ws:GetDescendants()) do
                     if door.Name:lower():find("door") and door:FindFirstChild("ClickDetector") then
                        fireclickdetector(door.ClickDetector)
                     end
                  end
               end
            end
         end
      end)
   end
end)

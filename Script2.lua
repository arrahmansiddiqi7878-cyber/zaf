local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Door Locked Hub", LoadingTitle = "Loading...", KeySystem = false})
local Tab = Win:CreateTab("Main", 4483362458)
getgenv().DS = {ESP = false, Breaker = false, Window = false, AutoLock = false, Fullbright = false}

local Plrs, Run, Ws = game:GetService("Players"), game:GetService("RunService"), game:GetService("Workspace")
local LP = Plrs.LocalPlayer

for _, v in ipairs({"ESP", "Breaker", "Window", "AutoLock", "Fullbright"}) do
   Tab:CreateToggle({Name = v, CurrentValue = false, Callback = function(val) getgenv().DS[v] = val end})
end

Run.RenderStepped:Connect(function()
   pcall(function()
      if DS.Fullbright then game:GetService("Lighting").Brightness, game:GetService("Lighting").ClockTime = 2, 14 end
      if not DS.ESP then return end
      for _, obj in pairs(Ws:GetChildren()) do
         if obj:IsA("Model") and obj ~= LP.Character and not Plrs:GetPlayerFromCharacter(obj) and obj:FindFirstChild("HumanoidRootPart") then
            local hl = obj:FindFirstChild("H") or Instance.new("Highlight", obj)
            hl.Name, hl.FillColor = "H", obj:GetAttribute("IsAnomaly") == true and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
         end
      end
   end)
end)

task.spawn(function()
   while task.wait(0.4) do
      pcall(function()
         local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
         if not hrp then return end
         for _, obj in pairs(Ws:GetDescendants()) do
            local name = obj.Name:lower()
            if DS.Breaker and (name:find("breaker") or name:find("power")) and obj:IsA("BasePart") then
               firetouchinterest(hrp, obj, 0) firetouchinterest(hrp, obj, 1)
            elseif DS.Window and (name:find("window") or name:find("monster")) and obj:IsA("Model") and obj.PrimaryPart then
               if (obj.PrimaryPart.Position - hrp.Position).Magnitude < 18 and DS.AutoLock then
                  for _, door in pairs(Ws:GetDescendants()) do
                     if door.Name:lower():find("door") and door:FindFirstChild("ClickDetector") then fireclickdetector(door.ClickDetector) end
                  end
               end
            end
         end
      end)
   end
end)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Door Locked Hub", LoadingTitle = "Loading...", KeySystem = false})
local Tab = Win:CreateTab("Main", 4483362458)
getgenv().DS = {ESP = false, Breaker = false, AutoKnock = false, Fullbright = false, WalkSpeed = false, InfSanity = false, SpeedValue = 16}

local Plrs, Run, Ws = game:GetService("Players"), game:GetService("RunService"), game:GetService("Workspace")
local LP = Plrs.LocalPlayer

for _, v in ipairs({"ESP", "Breaker", "AutoKnock", "Fullbright", "WalkSpeed", "InfSanity"}) do
   Tab:CreateToggle({Name = v, CurrentValue = false, Callback = function(val) getgenv().DS[v] = val end})
end

Tab:CreateSlider({
   Name = "Speed Value",
   Range = {16, 100},
   Increment = 1,
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      getgenv().DS.SpeedValue = Value
   end,
})

-- Advanced ESP Function for Visitors, Entities, and Knockers
local function updateESP()
   for _, obj in pairs(Ws:GetDescendants()) do
      if obj:IsA("Model") and obj ~= LP.Character and not Plrs:GetPlayerFromCharacter(obj) then
         local name = obj.Name:lower()
         if obj:FindFirstChild("Humanoid") or obj:FindFirstChild("Head") or name:find("visitor") or name:find("anomaly") or name:find("monster") or name:find("npc") or name:find("character") then
            if not obj:FindFirstChild("H") then
               local hl = Instance.new("Highlight")
               hl.Name = "H"
               hl.Adornee = obj
               -- Color code: Red if anomaly/monster, Green if normal visitor/human
               if name:find("anomaly") or name:find("monster") or name:find("entity") then
                  hl.FillColor = Color3.fromRGB(255, 0, 0)
               else
                  hl.FillColor = Color3.fromRGB(0, 255, 0)
               end
               hl.OutlineColor = Color3.fromRGB(255, 255, 255)
               hl.Parent = obj
            end
         end
      end
   end
end

Run.RenderStepped:Connect(function()
   pcall(function()
      if getgenv().DS.Fullbright then
         game:GetService("Lighting").Brightness = 2
         game:GetService("Lighting").ClockTime = 14
         game:GetService("Lighting").GlobalShadows = false
      end
      
      if getgenv().DS.WalkSpeed then
         local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
         if hum then hum.WalkSpeed = getgenv().DS.SpeedValue end
      end
      
      if not getgenv().DS.ESP then
         for _, v in pairs(Ws:GetDescendants()) do
            if v.Name == "H" then v:Destroy() end
         end
         return
      else
         updateESP()
      end
   end)
end)

-- Automation Loop for Breakers, Sanity, and Door Knocks/Peephole/Cameras
task.spawn(function()
   while task.wait(0.2) do
      pcall(function()
         local char = LP.Character
         local hrp = char and char:FindFirstChild("HumanoidRootPart")
         
         -- Infinite Sanity Lock
         if getgenv().DS.InfSanity then
            for _, container in pairs({LP:FindFirstChild("PlayerGui"), LP:FindFirstChild("PlayerScripts"), char}) do
               if container then
                  for _, v in pairs(container:GetDescendants()) do
                     local lname = v.Name:lower()
                     if (lname:find("sanity") or lname:find("fear") or lname:find("mind") or lname:find("stamina")) and (v:IsA("NumberValue") or v:IsA("IntValue")) then
                        v.Value = 100
                     end
                  end
               end
            end
         end

         if not hrp then return end
         
         -- Scan Workspace for Breakers and Door Interactions (Knocks, Peepholes, Cameras)
         for _, obj in pairs(Ws:GetDescendants()) do
            local name = obj.Name:lower()
            
            -- Auto Breaker / Power Switch
            if getgenv().DS.Breaker and (name:find("breaker") or name:find("fuse") or name:find("switch") or name:find("power") or name:find("light")) then
               if obj:IsA("BasePart") then
                  firetouchinterest(hrp, obj, 0)
                  firetouchinterest(hrp, obj, 1)
               elseif obj:IsA("ClickDetector") then
                  fireclickdetector(obj)
               end
            end
            
            -- Auto Knock / Peephole / Camera Interactor
            if getgenv().DS.AutoKnock and (name:find("knock") or name:find("peephole") or name:find("camera") or name:find("doorhole") or name:find("view")) then
               if obj:IsA("BasePart") and (obj.Position - hrp.Position).Magnitude < 20 then
                  firetouchinterest(hrp, obj, 0)
                  firetouchinterest(hrp, obj, 1)
               elseif obj:IsA("ClickDetector") then
                  fireclickdetector(obj)
               end
            end
         end
      end)
   end
end)

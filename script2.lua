local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Door Locked Hub", LoadingTitle = "Loading...", KeySystem = false})
local Tab = Win:CreateTab("Main", 4483362458)
getgenv().DS = {ESP = false, Breaker = false, Window = false, AutoLock = false, Fullbright = false, WalkSpeed = false, InfSanity = false, SpeedValue = 16}

local Plrs, Run, Ws = game:GetService("Players"), game:GetService("RunService"), game:GetService("Workspace")
local LP = Plrs.LocalPlayer

for _, v in ipairs({"ESP", "Breaker", "Window", "AutoLock", "Fullbright", "WalkSpeed", "InfSanity"}) do
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

Run.RenderStepped:Connect(function()
   pcall(function()
      if getgenv().DS.Fullbright then
         game:GetService("Lighting").Brightness = 2
         game:GetService("Lighting").ClockTime = 14
         game:GetService("Lighting").GlobalShadows = false
      end
      
      if getgenv().DS.WalkSpeed then
         local char = LP.Character
         local hum = char and char:FindFirstChildOfClass("Humanoid")
         if hum then
            hum.WalkSpeed = getgenv().DS.SpeedValue
         end
      end
      
      if not getgenv().DS.ESP then
         for _, v in pairs(Ws:GetDescendants()) do
            if v.Name == "H" then v:Destroy() end
         end
         return
      end

      for _, obj in pairs(Ws:GetDescendants()) do
         if obj:IsA("Model") and obj ~= LP.Character and not Plrs:GetPlayerFromCharacter(obj) then
            if obj:FindFirstChild("Humanoid") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") then
               if not obj:FindFirstChild("H") then
                  local hl = Instance.new("Highlight", obj)
                  hl.Name = "H"
                  hl.FillColor = Color3.fromRGB(0, 255, 0)
                  hl.OutlineColor = Color3.fromRGB(255, 255, 255)
               end
            end
         end
      end
   end)
end)

-- Automation Loop for Breaker, Window, and Infinite Sanity
task.spawn(function()
   while task.wait(0.3) do
      pcall(function()
         local char = LP.Character
         local hrp = char and char:FindFirstChild("HumanoidRootPart")
         
         -- Infinite Sanity Hook (Locks stat/value containers if present)
         if getgenv().DS.InfSanity then
            for _, v in pairs(LP:GetDescendants()) do
               if v:IsA("NumberValue") or v:IsA("IntValue") then
                  local lname = v.Name:lower()
                  if lname:find("sanity") or lname:find("fear") or lname:find("mind") then
                     v.Value = 100
                  end
               end
            end
            if char then
               for _, v in pairs(char:GetDescendants()) do
                  if v:IsA("NumberValue") or v:IsA("IntValue") then
                     local lname = v.Name:lower()
                     if lname:find("sanity") or lname:find("fear") or lname:find("mind") then
                        v.Value = 100
                     end
                  end
               end
            end
         end

         if not hrp then return end
         
         for _, obj in pairs(Ws:GetDescendants()) do
            local name = obj.Name:lower()
            if getgenv().DS.Breaker and (name:find("breaker") or name:find("fuse") or name:find("switch") or name:find("power")) then
               if obj:IsA("BasePart") then
                  firetouchinterest(hrp, obj, 0)
                  firetouchinterest(hrp, obj, 1)
               elseif obj:IsA("ClickDetector") then
                  fireclickdetector(obj)
               end
            end
            if getgenv().DS.Window and (name:find("window") or name:find("monster") or name:find("entity") or name:find("visitor")) then
               local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")) or (obj:IsA("BasePart") and obj)
               if targetPart and (targetPart.Position - hrp.Position).Magnitude < 30 and getgenv().DS.AutoLock then
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

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Keep the Door Locked Hub",
   LoadingTitle = "Door Locked Utility",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "DoorLockedHub",
      FileName = "Config"
   },
   KeySystem = false,
})

local Tab = Window:CreateTab("Main", 4483362458)

getgenv().DS = {
   ESP = false,
   Breaker = false,
   Window = false,
   AutoLock = false,
   Fullbright = false
}

local Plrs, Run, Ws = game:GetService("Players"), game:GetService("RunService"), game:GetService("Workspace")
local LP = Plrs.LocalPlayer

Tab:CreateToggle({
   Name = "Visitor & Anomaly ESP",
   CurrentValue = false,
   Flag = "ESPFlag",
   Callback = function(Value)
      getgenv().DS.ESP = Value
   end,
})

Tab:CreateToggle({
   Name = "Auto Breaker",
   CurrentValue = false,
   Flag = "BreakerFlag",
   Callback = function(Value)
      getgenv().DS.Breaker = Value
   end,
})

Tab:CreateToggle({
   Name = "Window Alert",
   CurrentValue = false,
   Flag = "WindowFlag",
   Callback = function(Value)
      getgenv().DS.Window = Value
   end,
})

Tab:CreateToggle({
   Name = "Auto-Lock Door",
   CurrentValue = false,
   Flag = "AutoLockFlag",
   Callback = function(Value)
      getgenv().DS.AutoLock = Value
   end,
})

Tab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "FullbrightFlag",
   Callback = function(Value)
      getgenv().DS.Fullbright = Value
   end,
})

Run.RenderStepped:Connect(function()
   if getgenv().DS.Fullbright then
      game:GetService("Lighting").Brightness = 2
      game:GetService("Lighting").ClockTime = 14
   end
   
   if not getgenv().DS.ESP then return end
   for _, obj in pairs(Ws:GetChildren()) do
      if obj:IsA("Model") and obj ~= LP.Character and not Plrs:GetPlayerFromCharacter(obj) and obj:FindFirstChild("HumanoidRootPart") then
         local hl = obj:FindFirstChild("H") or Instance.new("Highlight", obj)
         hl.Name = "H"
         hl.FillColor = obj:GetAttribute("IsAnomaly") == true and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
      end
   end
end)

task.spawn(function()
   while task.wait(0.4) do
      pcall(function()
         local char = LP.Character
         local hrp = char and char:FindFirstChild("HumanoidRootPart")
         if not hrp then return end

         for _, obj in pairs(Ws:GetDescendants()) do
            local name = obj.Name:lower()
            if getgenv().DS.Breaker and (name:find("breaker") or name:find("power")) and obj:IsA("BasePart") then
               firetouchinterest(hrp, obj, 0)
               firetouchinterest(hrp, obj, 1)
            elseif getgenv().DS.Window and (name:find("window") or name:find("monster")) and obj:IsA("Model") and obj.PrimaryPart then
               if (obj.PrimaryPart.Position - hrp.Position).Magnitude < 18 and getgenv().DS.AutoLock then
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

-- Delta Executor Ultimate Client-Side Script v3 (Highly Compatible)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Prevent duplicate UI instances
if CoreGui:FindFirstChild("MineSimulatorHub") then
	CoreGui.MineSimulatorHub:Destroy()
end

-- 1. CREATE DRAGGABLE MOBILE UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MineSimulatorHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 380)
MainFrame.Position = UDim2.new(0.5, -120, 0.3, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "  ⚡ Mine Hub Premium v3"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Minimize Button
local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 35, 0, 35)
Minimize.Position = UDim2.new(1, -35, 0, 0)
Minimize.BackgroundTransparency = 1
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(255, 50, 50)
Minimize.TextSize = 22
Minimize.Font = Enum.Font.SourceSansBold
Minimize.Parent = MainFrame

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, 0, 1, -35)
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 420)
ContentFrame.ScrollBarThickness = 4
ContentFrame.Parent = MainFrame

local function createButton(name, text, pos, parent)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0.9, 0, 0, 35)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	return btn
end

-- Create UI Elements
local AutoClickBtn = createButton("AutoClick", "Auto Click: OFF", UDim2.new(0.05, 0, 0.02, 0), ContentFrame)
local AutoRebirthBtn = createButton("AutoRebirth", "Auto Rebirth: OFF", UDim2.new(0.05, 0, 0.12, 0), ContentFrame)
local AutoCollectBtn = createButton("AutoCollect", "Auto Collect Items: OFF", UDim2.new(0.05, 0, 0.22, 0), ContentFrame)
local TeleportSafeBtn = createButton("TpSafe", "Teleport to Sky Safe", UDim2.new(0.05, 0, 0.32, 0), ContentFrame)
local AntiLagBtn = createButton("AntiLag", "FPS Boost (Anti-Lag)", UDim2.new(0.05, 0, 0.42, 0), ContentFrame)

-- Walkspeed Slider
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.54, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed Boost: Default"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextSize = 14
SpeedLabel.Parent = ContentFrame

local SpeedBtn = createButton("SpeedBtn", "Apply Speed (100)", UDim2.new(0.05, 0, 0.60, 0), ContentFrame)

-- JumpPower Slider
local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(0.9, 0, 0, 20)
JumpLabel.Position = UDim2.new(0.05, 0, 0.71, 0)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "JumpPower Boost: Default"
JumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
JumpLabel.Font = Enum.Font.SourceSansBold
JumpLabel.TextSize = 14
JumpLabel.Parent = ContentFrame

local JumpBtn = createButton("JumpBtn", "Apply Super Jump (120)", UDim2.new(0.05, 0, 0.77, 0), ContentFrame)


-- 2. LOOPS & FEATURE LOGIC
local autoClickActive = false
local autoRebirthActive = false
local autoCollectActive = false

local function updateToggleVisual(btn, active, onText, offText)
	if active then
		btn.Text = onText
		btn.BackgroundColor3 = Color3.fromRGB(15, 100, 45)
		btn.TextColor3 = Color3.fromRGB(150, 255, 150)
	else
		btn.Text = offText
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end

-- Auto-Click Logic
AutoClickBtn.MouseButton1Click:Connect(function()
	autoClickActive = not autoClickActive
	updateToggleVisual(AutoClickBtn, autoClickActive, "Auto Click: ACTIVE", "Auto Click: OFF")
end)

task.spawn(function()
	while true do
		task.wait(0.05)
		if autoClickActive then
			pcall(function()
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				-- Dynamic Remote Search for Clicking
				for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
					if v:IsA("RemoteEvent") and (v.Name:lower():find("click") or v.Name:lower():find("mine") or v.Name:lower():find("tap") or v.Name:lower():find("swing")) then
						v:FireServer()
					end
				end
				-- Tool Activation fallback
				local character = LocalPlayer.Character
				if character then
					local tool = character:FindFirstChildOfClass("Tool")
					if tool then tool:Activate() end
				end
			end)
		end
	end
end)

-- Improved Auto-Rebirth (Dynamic Search)
AutoRebirthBtn.MouseButton1Click:Connect(function()
	autoRebirthActive = not autoRebirthActive
	updateToggleVisual(AutoRebirthBtn, autoRebirthActive, "Auto Rebirth: ACTIVE", "Auto Rebirth: OFF")
end)

task.spawn(function()
	while true do
		task.wait(1.5) -- Safety delay to prevent crash
		if autoRebirthActive then
			pcall(function()
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				-- Dynamic Search across ALL ReplicatedStorage folders
				for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
					if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
						local name = v.Name:lower()
						if name:find("rebirth") or name:find("prestige") or name:find("ascend") then
							if v:IsA("RemoteEvent") then
								v:FireServer()
							else
								v:InvokeServer()
							end
						end
					end
				end
			end)
		end
	end
end)

-- Improved Auto-Collect Items (Workspace Vacuum)
AutoCollectBtn.MouseButton1Click:Connect(function()
	autoCollectActive = not autoCollectActive
	updateToggleVisual(AutoCollectBtn, autoCollectActive, "Auto Collecting Items...", "Auto Collect Items: OFF")
end)

task.spawn(function()
	while true do
		task.wait(0.3)
		if autoCollectActive then
			pcall(function()
				local char = LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if not root then return end

				-- Scan workspace for items
				for _, obj in ipairs(Workspace:GetDescendants()) do
					-- Check if the object contains a TouchTransmitter (things you need to walk over to pick up)
					if obj:IsA("TouchTransmitter") then
						local parent = obj.Parent
						if parent and parent:IsA("BasePart") then
							-- Bring the collectible part directly to your character's position
							firetouchinterest(root, parent, 0)
							firetouchinterest(root, parent, 1)
						end
					-- Or look directly for names matching items
					elseif obj:IsA("BasePart") then
						local name = obj.Name:lower()
						if name:find("coin") or name:find("gem") or name:find("crystal") or name:find("token") or name:find("ore") or name:find("boost") or name:find("loot") then
							-- Fire touch events safely via Executor exploit functions
							if firetouchinterest then
								firetouchinterest(root, obj, 0)
								firetouchinterest(root, obj, 1)
							else
								-- Fallback: pull it to you physically
								obj.CFrame = root.CFrame
							end
						end
					end
				end
			end)
		end
	end
end)

-- Teleport to Sky Safe Zone
TeleportSafeBtn.MouseButton1Click:Connect(function()
	pcall(function()
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			local safePart = Workspace:FindFirstChild("SafePlatform")
			if not safePart then
				safePart = Instance.new("Part", Workspace)
				safePart.Name = "SafePlatform"
				safePart.Size = Vector3.new(20, 2, 20)
				safePart.Position = Vector3.new(0, 2500, 0)
				safePart.Anchored = true
			end
			root.CFrame = safePart.CFrame + Vector3.new(0, 5, 0)
		end
	end)
end)

-- Walkspeed and Jump Boost Button Logic
local speedOn = false
SpeedBtn.MouseButton1Click:Connect(function()
	speedOn = not speedOn
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		if speedOn then
			hum.WalkSpeed = 100
			SpeedBtn.Text = "Normal Speed (16)"
			SpeedLabel.Text = "WalkSpeed Boost: Fast (100)"
		else
			hum.WalkSpeed = 16
			SpeedBtn.Text = "Apply Speed (100)"
			SpeedLabel.Text = "WalkSpeed Boost: Default"
		end
	end
end)

local jumpOn = false
JumpBtn.MouseButton1Click:Connect(function()
	jumpOn = not jumpOn
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		if jumpOn then
			hum.JumpPower = 120
			JumpBtn.Text = "Normal Jump (50)"
			JumpLabel.Text = "JumpPower Boost: High (120)"
		else
			hum.JumpPower = 50
			JumpBtn.Text = "Apply Super Jump (120)"
			JumpLabel.Text = "JumpPower Boost: Default"
		end
	end
end)

-- Anti-Lag Feature
AntiLagBtn.MouseButton1Click:Connect(function()
	pcall(function()
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("Decal") or v:IsA("Texture") then
				v:Destroy()
			elseif v:IsA("ParticleEmitter") or v:IsA("Sparkles") then
				v.Enabled = false
			end
		end
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		AntiLagBtn.Text = "FPS Boost Applied!"
		AntiLagBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
	end)
end)

-- Minimize Menu
local minimized = false
Minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	ContentFrame.Visible = not minimized
	if minimized then
		MainFrame.Size = UDim2.new(0, 240, 0, 35)
		Minimize.Text = "+"
	else
		MainFrame.Size = UDim2.new(0, 240, 0, 380)
		Minimize.Text = "-"
	end
end)

-- Anti-AFK Logic
LocalPlayer.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

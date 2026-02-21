--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--// Constants
local FOUR_HOURS = 14400

--// UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoonRiftGui"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 160)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.BackgroundTransparency = 1
MainFrame.Size = UDim2.new(0, 0, 0, 0)

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Moon Rift Controller"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.Gotham
ToggleButton.Text = "spawn moon rift 4h [OFF]"
ToggleButton.Parent = MainFrame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 12)

local CountdownLabel = Instance.new("TextLabel")
CountdownLabel.Size = UDim2.new(1, 0, 0, 30)
CountdownLabel.Position = UDim2.new(0, 0, 0.8, 0)
CountdownLabel.BackgroundTransparency = 1
CountdownLabel.Text = "Next Spawn: --:--:--"
CountdownLabel.TextColor3 = Color3.new(1, 1, 1)
CountdownLabel.TextScaled = true
CountdownLabel.Font = Enum.Font.Gotham
CountdownLabel.Parent = MainFrame

--// Animate UI On Load
task.wait()
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
	Size = UDim2.new(0, 260, 0, 160),
	BackgroundTransparency = 0
}):Play()

--// Notification
local function notify(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 5
		})
	end)
end

--// Spawn Function
local function spawnMoonRift()
	local args = {
		"SummonMoonRift",
		{
			Type = "Egg",
			Luck = 5,
			Time = 5
		}
	}

	ReplicatedStorage:WaitForChild("Shared")
		:WaitForChild("Framework")
		:WaitForChild("Network")
		:WaitForChild("Remote")
		:WaitForChild("RemoteFunction")
		:InvokeServer(unpack(args))

	notify("Moon Rift", "Moon Rift spawned!")
end

--// Loop Protection
local enabled = false
local loopRunning = false
local nextSpawnTime = 0

local function formatTime(seconds)
	local hrs = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d:%02d", hrs, mins, secs)
end

local function startLoop()
	if loopRunning then return end -- protection
	loopRunning = true
	
	task.spawn(function()
		while enabled do
			spawnMoonRift()
			nextSpawnTime = os.time() + FOUR_HOURS
			
			while enabled and os.time() < nextSpawnTime do
				local remaining = nextSpawnTime - os.time()
				CountdownLabel.Text = "Next Spawn: " .. formatTime(remaining)
				task.wait(1)
			end
		end
		
		loopRunning = false
		CountdownLabel.Text = "Next Spawn: --:--:--"
	end)
end

--// Button Animation
local function animateButton(color)
	TweenService:Create(ToggleButton, TweenInfo.new(0.25), {
		BackgroundColor3 = color
	}):Play()
end

ToggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	
	if enabled then
		ToggleButton.Text = "spawn moon rift 4h [ON]"
		animateButton(Color3.fromRGB(0,170,0))
		notify("Moon Rift Enabled", "Auto spawn started.")
		startLoop()
	else
		ToggleButton.Text = "spawn moon rift 4h [OFF]"
		animateButton(Color3.fromRGB(50,50,50))
		notify("Moon Rift Disabled", "Auto spawn stopped.")
	end
end)

--// Custom Dragging
local dragging = false
local dragStart
local startPos

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--// Right Ctrl Hide/Show (Animated)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Enum.KeyCode.RightControl then
		if MainFrame.Visible then
			TweenService:Create(MainFrame, TweenInfo.new(0.25), {
				Size = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1
			}):Play()
			task.wait(0.25)
			MainFrame.Visible = false
		else
			MainFrame.Visible = true
			TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
				Size = UDim2.new(0, 260, 0, 160),
				BackgroundTransparency = 0
			}):Play()
		end
	end
end)

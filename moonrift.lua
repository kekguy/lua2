-- Moon Rift UI Script
-- Place in StarterPlayerScripts or StarterGui as a LocalScript
-- Press RIGHT CTRL to show/hide the UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === Create ScreenGui ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoonRiftGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- === Main Frame ===
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 110)
mainFrame.Position = UDim2.new(0, 100, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 60, 140)
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- === Title Bar ===
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 20, 55)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(30, 20, 55)
titleFix.BorderSizePixel = 0
titleFix.ZIndex = 2
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "🌙 Moon Rift"
titleLabel.Size = UDim2.new(1, -65, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(200, 170, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 3
titleLabel.Parent = titleBar

-- Keybind hint in title bar
local keybindHint = Instance.new("TextLabel")
keybindHint.Text = "[RCtrl]"
keybindHint.Size = UDim2.new(0, 55, 1, 0)
keybindHint.Position = UDim2.new(1, -60, 0, 0)
keybindHint.BackgroundTransparency = 1
keybindHint.TextColor3 = Color3.fromRGB(100, 80, 150)
keybindHint.TextSize = 10
keybindHint.Font = Enum.Font.Gotham
keybindHint.TextXAlignment = Enum.TextXAlignment.Right
keybindHint.ZIndex = 3
keybindHint.Parent = titleBar

-- === Toggle Button ===
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "SpawnToggle"
toggleButton.Size = UDim2.new(1, -20, 0, 36)
toggleButton.Position = UDim2.new(0, 10, 0, 40)
toggleButton.BackgroundColor3 = Color3.fromRGB(35, 25, 65)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "spawn moon rift 4h"
toggleButton.TextColor3 = Color3.fromRGB(180, 150, 255)
toggleButton.TextSize = 13
toggleButton.Font = Enum.Font.GothamSemibold
toggleButton.AutoButtonColor = false
toggleButton.ZIndex = 2
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(80, 55, 130)
btnStroke.Thickness = 1
btnStroke.Parent = toggleButton

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "● IDLE"
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 82)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(100, 100, 130)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 2
statusLabel.Parent = mainFrame

-- Countdown label
local countdownLabel = Instance.new("TextLabel")
countdownLabel.Text = ""
countdownLabel.Size = UDim2.new(1, -20, 0, 20)
countdownLabel.Position = UDim2.new(0, 10, 0, 82)
countdownLabel.BackgroundTransparency = 1
countdownLabel.TextColor3 = Color3.fromRGB(140, 255, 160)
countdownLabel.TextSize = 11
countdownLabel.Font = Enum.Font.Gotham
countdownLabel.TextXAlignment = Enum.TextXAlignment.Left
countdownLabel.ZIndex = 2
countdownLabel.Visible = false
countdownLabel.Parent = mainFrame

-- === State ===
local isEnabled = false
local spawnThread = nil
local isVisible = true
local isTweening = false

-- === Rift Logic ===
local INTERVAL = 4 * 60 * 60 -- 4 hours in seconds

local function formatTime(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = math.floor(seconds % 60)
	return string.format("● next in %02d:%02d:%02d", h, m, s)
end

local function invokeRift()
	local success, err = pcall(function()
		local args = {
			"SummonMoonRift",
			{ Type = "Egg", Luck = 5, Time = 5 }
		}
		game:GetService("ReplicatedStorage")
			:WaitForChild("Shared")
			:WaitForChild("Framework")
			:WaitForChild("Network")
			:WaitForChild("Remote")
			:WaitForChild("RemoteFunction")
			:InvokeServer(unpack(args))
	end)
	if not success then
		warn("[MoonRift] Error: " .. tostring(err))
	end
end

local function setEnabled(state)
	isEnabled = state

	if isEnabled then
		TweenService:Create(toggleButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(60, 30, 110)
		}):Play()
		btnStroke.Color = Color3.fromRGB(140, 90, 255)
		toggleButton.TextColor3 = Color3.fromRGB(220, 200, 255)
		statusLabel.Visible = false
		countdownLabel.Visible = true

		spawnThread = task.spawn(function()
			while isEnabled do
				invokeRift()
				local remaining = INTERVAL
				while isEnabled and remaining > 0 do
					countdownLabel.Text = formatTime(remaining)
					task.wait(1)
					remaining -= 1
				end
			end
		end)
	else
		TweenService:Create(toggleButton, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(35, 25, 65)
		}):Play()
		btnStroke.Color = Color3.fromRGB(80, 55, 130)
		toggleButton.TextColor3 = Color3.fromRGB(180, 150, 255)
		statusLabel.Text = "● IDLE"
		statusLabel.TextColor3 = Color3.fromRGB(100, 100, 130)
		statusLabel.Visible = true
		countdownLabel.Visible = false
		countdownLabel.Text = ""

		if spawnThread then
			task.cancel(spawnThread)
			spawnThread = nil
		end
	end
end

toggleButton.MouseButton1Click:Connect(function()
	setEnabled(not isEnabled)
end)

toggleButton.MouseEnter:Connect(function()
	if not isEnabled then
		TweenService:Create(toggleButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(50, 35, 90)
		}):Play()
	end
end)

toggleButton.MouseLeave:Connect(function()
	if not isEnabled then
		TweenService:Create(toggleButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(35, 25, 65)
		}):Play()
	end
end)

-- === Show / Hide Animation (Right Ctrl) ===
local FULL_SIZE   = UDim2.new(0, 220, 0, 110)
local SMALL_SIZE  = UDim2.new(0, 200, 0, 95)

local function getTextElements()
	local result = {}
	for _, obj in ipairs(mainFrame:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			table.insert(result, obj)
		end
	end
	return result
end

local function getFrameElements()
	local result = {}
	for _, obj in ipairs(mainFrame:GetDescendants()) do
		if obj:IsA("Frame") then
			table.insert(result, obj)
		end
	end
	return result
end

local function setUIVisible(visible)
	if isTweening then return end
	isTweening = true
	isVisible = visible

	if visible then
		-- Start from small + invisible
		mainFrame.Size = SMALL_SIZE
		mainFrame.BackgroundTransparency = 1
		stroke.Transparency = 1
		for _, obj in ipairs(getTextElements()) do
			obj.TextTransparency = 1
		end
		for _, obj in ipairs(getFrameElements()) do
			obj.BackgroundTransparency = 1
		end
		mainFrame.Visible = true

		-- Animate in: scale up with bounce + fade
		TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = FULL_SIZE,
			BackgroundTransparency = 0,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0,
		}):Play()
		for _, obj in ipairs(getTextElements()) do
			TweenService:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {
				TextTransparency = 0,
			}):Play()
		end
		for _, obj in ipairs(getFrameElements()) do
			TweenService:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.05), {
				BackgroundTransparency = 0,
			}):Play()
		end

		task.delay(0.35, function() isTweening = false end)
	else
		-- Animate out: scale down + fade
		TweenService:Create(mainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = SMALL_SIZE,
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1,
		}):Play()
		for _, obj in ipairs(getTextElements()) do
			TweenService:Create(obj, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1,
			}):Play()
		end
		for _, obj in ipairs(getFrameElements()) do
			TweenService:Create(obj, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
			}):Play()
		end

		task.delay(0.25, function()
			mainFrame.Visible = false
			isTweening = false
		end)
	end
end

-- Right Ctrl keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		setUIVisible(not isVisible)
	end
end)

-- === Draggable Logic ===
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

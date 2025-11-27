--// GUI Script Wrapper for Enchant Automation

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local LocalData = require(ReplicatedStorage.Client.Framework.Services.LocalData)

local RemoteContainer = ReplicatedStorage.Shared.Framework.Network.Remote
local RemoteFunction = RemoteContainer.RemoteFunction
local RemoteEvent = RemoteContainer.RemoteEvent

local TARGET_ENCHANTS = {
    { Id = "ultra-roller" },
    { Id = "shiny-seeker" }
}
local REROLL_CURRENCY = "Gems"
local COOLDOWN_BETWEEN_REROLLS = 0.5
local Running = false -- Control flag

--// Utility Functions
local function findPetById(petId)
    local playerData = LocalData:Get()
    if not (playerData and playerData.Pets) then return nil end
    for _, pet in ipairs(playerData.Pets) do
        if pet and pet.Id == petId then return pet end
    end
    return nil
end

local function getFoundTargetEnchant(pet)
    local enchants = pet.Enchants or {}
    for i, currentEnchant in ipairs(enchants) do
        for _, targetEnchant in ipairs(TARGET_ENCHANTS) do
            if currentEnchant.Id == targetEnchant.Id then return targetEnchant, i end
        end
    end
    return nil, nil
end

local function enchantShinyPet(petId, statusLabel)
    local petData = findPetById(petId)
    if not petData then return end
    
    local foundTarget, foundSlot
    
    while Running do
        local currentPet = findPetById(petId)
        if not currentPet then warn("Lost access to pet data: " .. petId); return end
        
        foundTarget, foundSlot = getFoundTargetEnchant(currentPet)
        if foundTarget then
            statusLabel.Text = "Found target enchant: " .. foundTarget.Id
            break
        end
        
        statusLabel.Text = "Rerolling enchants..."
        RemoteFunction:InvokeServer("RerollEnchants", petId, REROLL_CURRENCY)
        task.wait(COOLDOWN_BETWEEN_REROLLS)
    end

    local neededTarget
    for _, target in ipairs(TARGET_ENCHANTS) do
        if target.Id ~= foundTarget.Id then neededTarget = target; break end
    end
    
    if not neededTarget then return end
    
    local slotToReroll = (foundSlot == 1) and 2 or 1
    
    while Running do
        local currentPet = findPetById(petId)
        if not currentPet then warn("Lost access to pet data: " .. petId); return end
        
        local enchantInSlot = (currentPet.Enchants or {})[slotToReroll]
        
        if enchantInSlot and enchantInSlot.Id == neededTarget.Id then
            statusLabel.Text = "Both enchants found!"
            break
        end
        
        statusLabel.Text = "Rerolling slot " .. slotToReroll
        RemoteEvent:FireServer("RerollEnchant", petId, slotToReroll)
        task.wait(COOLDOWN_BETWEEN_REROLLS)
    end
end

local function main(statusLabel)
    if not LocalData:IsReady() then LocalData.DataReady:Wait() end
    
    local playerData = LocalData:Get()
    local teamPetIds
    local equippedTeamIndex
    
    repeat
        task.wait(1)
        equippedTeamIndex = playerData.TeamEquipped
        if equippedTeamIndex then
            local equippedTeam = playerData.Teams and playerData.Teams[equippedTeamIndex]
            if equippedTeam and equippedTeam.Pets and #equippedTeam.Pets > 0 then
                teamPetIds = equippedTeam.Pets
            end
        end
    until teamPetIds or not Running
    
    if not Running then return end

    for i, petId in ipairs(teamPetIds) do
        local petData = findPetById(petId)
        if petData and petData.Shiny then
            statusLabel.Text = "Enchanting shiny pet " .. tostring(petId)
            enchantShinyPet(petId, statusLabel)
        end
        
        if i < #teamPetIds then
            task.wait(2)
        end
        if not Running then break end
    end

    statusLabel.Text = "Finished processing pets!"
end

--// GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EnchantGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "✨ Enchant Helper"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -10, 0, 40)
Status.Position = UDim2.new(0, 5, 0, 35)
Status.Text = "Idle"
Status.TextWrapped = true
Status.TextColor3 = Color3.new(1, 1, 1)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.Gotham
Status.TextSize = 14
Status.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 100)
ToggleButton.Text = "▶ Start"
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

--------------------------------------------------------------------------------
--👉 HIDE / SHOW BUTTON ADDED HERE
--------------------------------------------------------------------------------
local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0, 25, 0, 25)
HideButton.Position = UDim2.new(1, -30, 0, 5)
HideButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
HideButton.Text = "X"
HideButton.TextColor3 = Color3.new(1, 1, 1)
HideButton.Font = Enum.Font.GothamBold
HideButton.TextSize = 14
HideButton.Parent = Frame

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 6)
HideCorner.Parent = HideButton

local ReopenButton = Instance.new("TextButton")
ReopenButton.Size = UDim2.new(0, 40, 0, 40)
ReopenButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ReopenButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ReopenButton.Text = "📜"
ReopenButton.TextSize = 20
ReopenButton.TextColor3 = Color3.new(1, 1, 1)
ReopenButton.Font = Enum.Font.GothamBold
ReopenButton.Visible = false
ReopenButton.Parent = ScreenGui

local ReopenCorner = Instance.new("UICorner")
ReopenCorner.CornerRadius = UDim.new(0, 12)
ReopenCorner.Parent = ReopenButton

HideButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
    ReopenButton.Visible = true
end)

ReopenButton.MouseButton1Click:Connect(function()
    Frame.Visible = true
    ReopenButton.Visible = false
end)
--------------------------------------------------------------------------------

--// Button Logic
ToggleButton.MouseButton1Click:Connect(function()
    if Running then
        Running = false
        ToggleButton.Text = "▶ Start"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
        Status.Text = "Stopped"
    else
        Running = true
        ToggleButton.Text = "⏹ Stop"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(130, 60, 60)
        Status.Text = "Starting..."
        task.spawn(function()
            main(Status)
            Running = false
            ToggleButton.Text = "▶ Start"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
        end)
    end
end)

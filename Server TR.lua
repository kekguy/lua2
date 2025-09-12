while task.wait() do
local args = {
    "UsePotion",
    "Coins",
    1,
    10
}
game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("RemoteEvent"):FireServer(unpack(args))

end

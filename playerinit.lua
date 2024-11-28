local ReplStorage = game:GetService("ReplicatedStorage")
local Modules, Events = ReplStorage:WaitForChild("Modules")

local Entity = require(Modules:WaitForChild("Entity"))
local Weapon = Modules:WaitForChild("BaseWeapon")
local MeleeWeapon = require(Weapon:WaitForChild("MeleeWeapon"))

local Players = game:GetService("Players")
local PlayerList = {}
local function onPlayerAdded(Player: Player)
	PlayerList[Player.Name] = {}
	PlayerList[Player.Name]["player"] = Player
	local function onCharacterAdded(Character: Model)
		Character.PrimaryPart = Character:WaitForChild("HumanoidRootPart")
		
		-- Create Entity for Character
		local CharacterEntity = Entity.new(Character, {"Health", "Defense", "Stamina"})
		
		-- Block Placement and Carry
		local newWeldConstraint: WeldConstraint = Instance.new("WeldConstraint", Character.PrimaryPart)
		newWeldConstraint.Name = "CarryWeldConstraint"
		newWeldConstraint.Part0 = Character.PrimaryPart
		
		-- Movement Dash
		local newLineVelocity: LinearVelocity = Instance.new("LinearVelocity", Character.PrimaryPart)
		newLineVelocity.Name = "DashVelocity"
		newLineVelocity.Attachment0 = Character.PrimaryPart:WaitForChild("RootAttachment")
		newLineVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
		newLineVelocity.MaxForce = math.huge
		newLineVelocity.Enabled = false
		
		local katana = MeleeWeapon.new(game.ReplicatedStorage.Weapons:FindFirstChild("Katana"))
		-- Weapon Give
		
		katana:GiveTo(Player)
		PlayerList[Player.Name]["weapon"] = katana
		
		katana:Equip()

	end
	
	if Player.Character then
		onCharacterAdded(Player.Character)
	end
	Player.CharacterAdded:Connect(onCharacterAdded)
	Player.CharacterRemoving:Connect(function()
		
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, Player in pairs(Players:GetChildren()) do
	if Player and Player:IsA("Player") then
		onPlayerAdded(Player)
	end
end

Players.PlayerRemoving:Connect(function(player)
	if PlayerList[player.Name] then
		PlayerList[player.Name]["weapon"]:Destroy()
	end
end)
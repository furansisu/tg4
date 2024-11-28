local RunService = game:GetService("RunService")
local ReplStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Modules = ReplStorage:WaitForChild("Modules")
local Events = ReplStorage:WaitForChild("Events")
local Entity = require(Modules:WaitForChild("Entity"))

-- EVENTS
local ClientStamina = Events:WaitForChild("ClientStaminaUpdate")
local EntityUpdate = Events:WaitForChild("EntityUpdate")
--

-- VARIABLES
local replenishDelay = 1
--

-- ACTIVE VARIABLES
local lastStaminaUsed = {}
--

local module = {}

local function onStaminaUpdate(Player, oldStamina, newStamina)
	-- USES THE CLIENTS STAMINA VALUES (SANITY CHECK NEEDED)
	local serverEntity = Entity.Entities[Player.Character]
	lastStaminaUsed[Player.Character] = {
		time = tick(),
		old = oldStamina,
		new = newStamina,
	}
end

function module.onUpdateCharacterStamina(Character: Model, Entity, time: number, deltaTime: number)
	if lastStaminaUsed[Character] == nil then
		lastStaminaUsed[Character] = {
			time = tick(), 
			old = 5,
			new = 5,
		}
	end

	local canReplenish = (tick() - lastStaminaUsed[Character].time) >= replenishDelay

	if canReplenish then
		Entity:RegenStamina((Entity.Statistics.StaminaReplenishSpeed * deltaTime))
	else
		Entity:SpendStamina(lastStaminaUsed[Character].old - lastStaminaUsed[Character].new)
	end
	
	lastStaminaUsed[Character].old = lastStaminaUsed[Character].new
end


ClientStamina.OnServerEvent:Connect(onStaminaUpdate)

return module

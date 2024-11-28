local RunService = game:GetService("RunService")
local ReplStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Modules = ReplStorage:WaitForChild("Modules")
local Events = ReplStorage:WaitForChild("Events")
local Entity = require(Modules:WaitForChild("Entity"))

-- EVENTS
local debug = Events:WaitForChild("debug")
--

-- MODULES
local StaminaUpdater = require(script:WaitForChild("Stamina"))
--


local function onStep(time: number, deltaTime: number)
	for Character, Entity in pairs(Entity.Entities) do
		if table.find(Entity.Logs.chosenComponents, "Stamina") then
			StaminaUpdater.onUpdateCharacterStamina(Character, Entity, time, deltaTime)
		end
	end
end

debug.OnServerEvent:Connect(function(Player, Model, Amount, Attacker)
	local Entity = Entity.Entities[Model]
	Entity:Damage(Amount, Attacker)
end)


RunService.Stepped:Connect(onStep)
local RunService = game:GetService("RunService")
local ReplStorage = game:GetService("ReplicatedStorage")
local Events = ReplStorage:WaitForChild("Events")

local Stamina = {}
Stamina.__index = Stamina

-->> DEFAULT VALUES
Stamina.defaultMaxStamina = 5
Stamina.defaultReplenishSpeed = .5

-->> CONSTANT
local replenishDelay = 1

function Stamina.new(Entity)
	local self = setmetatable({}, Stamina)
	
	-->> ASSIGN THE VARIABLES
	Entity.Statistics.StaminaReplenishSpeed = Stamina.defaultReplenishSpeed
	Entity.Statistics.MaxStamina = Stamina.defaultMaxStamina
	Entity.Stamina = Stamina.defaultMaxStamina
	Entity.Logs.lastSpentStamina = tick()
	
	
	-->> GIVE THE ENTITY THE FUNCTIONS
	Entity.RegenStamina = Stamina.RegenStamina
	Entity.SpendStamina = Stamina.SpendStamina
	
	-->> CONNECT RUNSERVICE TO FUNCTION STAMINA
	RunService.Stepped:Connect(function(time: number, deltaTime: number)
		self.StaminaAutomaticRegen(Entity, time, deltaTime)
	end)
	-->> CONNECT PLAYER STAMINA USE
	Events.ClientStaminaUpdate.OnServerEvent:Connect(function(player, amount: number)
		Entity:SpendStamina(math.abs(amount))
	end)
	
	return self
end

-->> FUNCTIONS TO ATTACH TO THE ENTITY
function Stamina:RegenStamina(amount: number)
	self.Stamina = math.clamp(self.Stamina + amount, 0, self.Statistics.MaxStamina)
end

function Stamina:SpendStamina(amount: number)
	self.Stamina = math.clamp(self.Stamina - amount, 0, self.Statistics.MaxStamina)
	self.Logs.lastSpentStamina = tick()
end
--<<

-->> self IS STILL ENTITY
function Stamina:StaminaAutomaticRegen(time, deltaTime: number)
	if (tick() - self.Logs.lastSpentStamina) >= replenishDelay then
		-->> CAN START REGENERATING
		self:RegenStamina(self.Statistics.StaminaReplenishSpeed * deltaTime)
	end
end

--[[
	ENTITY STAMINA REPLENISH IS DONE IN
	-- EntityInitializer.Stamina
	-- located in ServerScriptService
--]]

return Stamina

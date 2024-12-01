local ReplStorage = game:GetService("ReplicatedStorage")
local Events = ReplStorage:WaitForChild("Events")

local Health = {}
Health.__index = Health

-->> DEFAULT VALUES
Health.defaultMaxHealth = 1000

function Health.new(Entity)
	-->> ASSIGN THE VARIABLES
	Entity.Statistics.MaxHealth = Health.defaultMaxHealth
	Entity.Health = Health.defaultMaxHealth
	
	-->> GIVE THE ENTITY THE FUNCTIONS
	Entity.Regen = Health.Regen
	Entity.Damage = Health.Damage
end

-->> CALCULATING FUNCTIONS
local function defenseCalculation(Amount, Defense)
	if not Defense then
		return Amount
	else
		return math.floor(Amount - Defense)
	end
end

function Health:Regen(amount: number)
	self.Health = math.clamp(self.Health + amount, 0, self.Statistics.MaxHealth)
	self.Model.Humanoid.Health = self.Health
end

function Health:Damage(amount: number, attacker: Entity)
	local actualDmg = defenseCalculation(amount, self.Statistics.Defense)
	self.Health = math.clamp(self.Health - actualDmg, 0, self.Statistics.MaxHealth)
	self.Logs.lastAttackedBy = attacker
	Events.DamageIndicator:FireAllClients(actualDmg, self.Model:GetPivot().Position)
	self.FakeHumanoid.Health = self.Health
end

return Health

local RunService = game:GetService("RunService")
local ReplStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Events = ReplStorage:WaitForChild("Events")
local EntityUpdate = Events:WaitForChild("EntityUpdate")

local Entity = {}
Entity.__index = Entity
Entity.Entities = {}

-->> COMPONENT MODULES
local Components = {
	Health = require(script.Health),
	Defense = require(script.Defense),
	Stamina = require(script.Stamina),
	Weapon = require(script.Weapon),
	Player = require(script.Player),
	HitStun = require(script.HitStun)
}
--<<

function Entity.new(Model: Model, chosenComponents: {string})
	local self = setmetatable({}, Entity)
	self.Name = Model.Name
	
	self.Statistics = {}
	
	self.Logs = {
		chosenComponents = chosenComponents,
		componentData = {},
	}
	self.Model = Model
	
	-- -- -- >>> APPLY COMPONENTS
	for _, componentName in pairs(chosenComponents) do
		if Components[componentName] then
			self.Logs.componentData[componentName] = Components[componentName].new(self)
		end
	end
	-- -- -- <<<
	
	Entity.Entities[Model] = self
	EntityUpdate:FireAllClients(self)
	
	-- this is for RaycastHitboxv4 because I'm too lazy to write hitdetection code
	self.FakeHumanoid = Model:FindFirstChild("Humanoid", true)
	if not self.FakeHumanoid then
		self.FakeHumanoid = Instance.new("Humanoid", Model)
		self.FakeHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
	
	return self
end

function Entity.forceUpdateClient(Player: Player)
	for _, self in pairs(Entity.Entities) do
		EntityUpdate:FireClient(Player, self)
	end
end

function Entity.readReplicatedData(dataObject: ObjectValue)
	local givenEntity = {}
	for _, data in pairs(dataObject:GetChildren()) do
		if not data:IsA("Folder") then
			givenEntity[data.Name] = data.Value
		else
			givenEntity[data.Name] = {}
			for _, subData in pairs(data:GetChildren()) do
				givenEntity[data.Name][subData.Name] = subData.Value
			end
		end
	end
	return givenEntity
end

function Entity.getEntityFromModel(Model: Model)
	if RunService:IsServer() then
		return Entity.Entities[Model]
	elseif RunService:IsClient() then
		for _, EntityData in pairs(ReplStorage:WaitForChild("Data"):GetChildren()) do
			if EntityData.Model.Value == Model then
				return Entity.readReplicatedData(EntityData)
			end
		end
	end
end

function Entity.getEntityFromPlayer(Player: Player)
	return Entity.getEntityFromModel(Player.Character)
end

function Entity.getPlayerFromEntity(Entity)
	return Entity.Player
end

function Entity:SetLogVariable(name: string, value: any)
	self.Logs[name] = value
end

return Entity

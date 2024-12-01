local ReplStorage = game:GetService("ReplicatedStorage")
local Events = ReplStorage:WaitForChild("Events")
local EntityUpdate = Events:WaitForChild("EntityUpdate")

local Defense = {}
Defense.__index = Defense

-->> DEFAULT VALUES
Defense.defaultDefense = 0

function Defense.new(Entity)
	-->> ASSIGN THE VARIABLES
	Entity.Statistics.Defense = Defense.defaultDefense
end

return Defense

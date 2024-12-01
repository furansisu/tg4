local ReplStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Events = ReplStorage:WaitForChild("Events")
local EntityUpdate = Events:WaitForChild("EntityUpdate")

local Player = {}
Player.__index = Player

function Player.new(Entity)
	-->> ASSIGN THE VARIABLES
	Entity.Player = Players:GetPlayerFromCharacter(Entity.Model)
end

return Player

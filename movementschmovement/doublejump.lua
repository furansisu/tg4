local ReplStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")

local Modules = ReplStorage:WaitForChild("Modules")

-- MODULES
local Entity = require(Modules:WaitForChild("Entity"))
local Stamina = require(Player.PlayerScripts.EntityHandler.Stamina)
--

local module = {}
module.doubleJumped = false

local neededDoubleJumpStamina = .5

function module.DoubleJump(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
	local CharacterEntity = Entity.Entities[Character]
	if inputState == Enum.UserInputState.Begin then
		local enoughStamina = CharacterEntity.Stamina - neededDoubleJumpStamina > 0
		if Humanoid:GetState() == Enum.HumanoidStateType.Freefall and not module.doubleJumped and enoughStamina then
			module.doubleJumped = true
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			
			Stamina.spendStamina(neededDoubleJumpStamina)
		end
	end
	return Enum.ContextActionResult.Pass
end

Humanoid.StateChanged:Connect(function(oldState, newState)
	if newState == Enum.HumanoidStateType.Landed then
		module.doubleJumped = false
	end
end)

return module

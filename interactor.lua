local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- MODULES
local CarryBlock = require(script:WaitForChild("CarryBlock"))
--

local Actions = {
	CarryBlock = {
		actionName = "CARRY_BLOCK",
		functionToBind = CarryBlock.CarryBlock,
		createTouchButton = true,
		inputTypes = unpack({
			Enum.KeyCode.E
		})
	}
}

for ActionIndex, Action in pairs(Actions) do
	ContextActionService:BindAction(Action.actionName, Action.functionToBind, Action.createTouchButton, Action.inputTypes)
end
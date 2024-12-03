local CAS = game:GetService("ContextActionService")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- MODULES
local Dash = require(script:WaitForChild("Dash"))
local DoubleJump = require(script:WaitForChild("DoubleJump"))
--

local Actions = {
	Dash = {
		actionName = "DASH",
		functionToBind = Dash.Dash,
		createTouchButton = true,
		inputTypes = unpack({
			Enum.KeyCode.LeftShift
		})
	},
	DoubleJump = {
		actionName = "DOUBLE_JUMP",
		functionToBind = DoubleJump.DoubleJump,
		createTouchButton = false,
		inputTypes = unpack({
			Enum.KeyCode.Space
		})
	}
}

for ActionIndex, Action in pairs(Actions) do
	CAS:BindAction(Action.actionName, Action.functionToBind, Action.createTouchButton, Action.inputTypes)
end


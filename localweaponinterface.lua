-- CLIENT
local plr = game:GetService("Players").LocalPlayer
local cas = game:GetService("ContextActionService")

-- CONFIG
local primaryButton = Enum.UserInputType.MouseButton1
local secondaryButton = Enum.UserInputType.MouseButton2
local tertiaryButton = Enum.KeyCode.R
local switchWeaponButton = Enum.KeyCode.Q

-- VARIABLES
local button_hold = 0
local heartbeat

function Primary(actionName : string, inputState : Enum.UserInputState, inputObject : InputObject)
	script.RE_primary:FireServer(inputState)
	return Enum.ContextActionResult.Pass
end

function Secondary(actionName : string, inputState : Enum.UserInputState, inputObject : InputObject)
	script.RE_secondary:FireServer(inputState)
	return Enum.ContextActionResult.Pass
end

function Tertiary(actionName : string, inputState : Enum.UserInputState, inputObject : InputObject)
	script.RE_tertiary:FireServer(inputState)
	return Enum.ContextActionResult.Pass
end

function Switch(actionName : string, inputState : Enum.UserInputState, inputObject : InputObject)
	if inputState == Enum.UserInputState.Begin then
		button_hold = tick()
		heartbeat = game["Run Service"].Heartbeat:Connect(function()
			if tick() - button_hold >= 0.5 then
				-- UNEQUIP ALL WEAPONS
				script.RE_holster:FireServer(inputState)
				heartbeat:disconnect()
			end
		end)
	elseif inputState == Enum.UserInputState.End and tick() - button_hold < 0.5 then
		-- SWITCH WEAPONS
		script.RE_switch:FireServer(inputState)
		heartbeat:disconnect()
	end
end

cas:BindAction("Primary", Primary, true, primaryButton)
cas:BindAction("Secondary", Secondary, true, secondaryButton)
cas:BindAction("Tertiary", Tertiary, true, tertiaryButton)
cas:BindAction("Switch", Switch, true, switchWeaponButton)
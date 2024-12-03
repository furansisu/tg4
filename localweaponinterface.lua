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

-- input buffer
local lastInput = {
	action = nil,
	inputState = nil,
	inputTime = 0,
}

function Primary(actionName : string, inputState : Enum.UserInputState, inputObject : InputObject)
	if lastInput.action ~= actionName and tick() - lastInput.inputTime <= 0.1 then
		return
	end
	
	script.RE_primary:FireServer(inputState)
	lastInput.action = actionName
	lastInput.inputState = inputState
	lastInput.inputTime = tick()

	return Enum.ContextActionResult.Pass
end

function Secondary(actionName : string, inputState : Enum.UserInputState, inputObject : InputObject)
	if lastInput.action ~= actionName and tick() - lastInput.inputTime <= 0.1 then
		return
	end
	
	script.RE_secondary:FireServer(inputState)
	lastInput.action = actionName
	lastInput.inputState = inputState
	lastInput.inputTime = tick()
	return Enum.ContextActionResult.Pass
end

function Tertiary(actionName : string, inputState : Enum.UserInputState, inputObject : InputObject)
	if lastInput.action ~= actionName and tick() - lastInput.inputTime <= 0.1 then
		return
	end

	script.RE_tertiary:FireServer(inputState)
	lastInput.action = actionName
	lastInput.inputState = inputState
	lastInput.inputTime = tick()
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
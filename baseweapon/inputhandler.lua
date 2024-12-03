local Input = {}

local hold_threshold = 0.2 --time it takes when holding down a button before it is not considered a click anymore

local function bindStateInput(Weapon, inputState: Enum.UserInputState, state)
	local capitalizedState = string.sub(string.upper(state), 1, 1).. string.sub(state, 2)
	if not Weapon.equipped then return end
	if inputState == Enum.UserInputState.Begin then
		Weapon[capitalizedState.. "Down"](Weapon)
		Weapon[state.. "_hold_time"] = tick()
	elseif inputState == Enum.UserInputState.End then
		local hold_duration = tick() - Weapon[state.. "_hold_time"]
		if hold_duration < hold_threshold then
			Weapon[capitalizedState.. "Click"](Weapon)	
		end
		Weapon[capitalizedState.. "Up"](Weapon)
	end
end

function Input.controlInput(Weapon)
	local Events = Weapon.holder.Model:WaitForChild("Events", 1)
	local states = {"primary", "secondary", "tertiary"}

	for index, state in pairs(states) do
		Weapon[state.. "_hold_time"] = 0
		Weapon[state.. "_connection"] = Events:FindFirstChild("RE_".. state).Event:Connect(function(inputState)
			bindStateInput(Weapon, inputState, state)
		end)
	end
end



return Input

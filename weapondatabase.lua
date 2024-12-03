local WeaponDatabase = {}

local Modules = {}
for _, Module in pairs(script:GetChildren()) do
	if Module:IsA("ModuleScript") then
		Modules[Module.Name] = require(Module)
	end
end

function WeaponDatabase:ApplyDataToWeapon()
	for State, Action in pairs(self.Actions) do
		if Modules[Action] then
			Modules[Action].loadSelfData(self)
			for FunctionName, Function in pairs(Modules[Action]) do
				if string.find(FunctionName, State) then
					self[FunctionName] = Function
				end
			end
		else
			warn("Weapon ".. self.name.. " wants ".. Action.. " but it doesnt exist")
		end
	end
end

return WeaponDatabase

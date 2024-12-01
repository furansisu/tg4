local WeaponDatabase = {}

local Modules = {}
for _, Module in pairs(script:GetChildren()) do
	if Module:IsA("ModuleScript") then
		Modules[Module.Name] = require(Module)
	end
end

function WeaponDatabase:ApplyDataToWeapon()
	if not Modules[self.name] then return warn("Weapon name has no database") end
	for index, value in pairs(Modules[self.name]) do
		self[index] = value
	end
	self:loadSelfData()
end

return WeaponDatabase

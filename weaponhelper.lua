local WeaponHelper = {}
local WeaponModule = require(game.ReplicatedStorage.Modules.BaseWeapon)
local Entity = require(game.ReplicatedStorage.Modules.Entity)

function WeaponHelper.GiveWeapon(Entity, name: string, slot: number)
	local weaponModel = WeaponHelper.ValidateWeapon(name)
	if not weaponModel then
		warn("Invalid weapon")
		return
	end

	local wepSlot = "Weapon"..slot

	if Entity.Weapons[wepSlot] ~= nil then
		WeaponHelper.RemoveWeapon(Entity, slot)
	end

	local weapon = WeaponModule.new(weaponModel)
	weapon:GiveTo(Entity, slot)
	
	print(name.. " giving to "..Entity.Name)
end

function WeaponHelper.ValidateWeapon(name : string)
	if name ~= "" then
		--Find in Weapons folder
		local weaponModel = game.ReplicatedStorage.Weapons:FindFirstChild(name)
		if not weaponModel then
			warn("No weapon model found for: "..name)
			return false
		end
		
		return weaponModel
	end
end

function WeaponHelper.RemoveWeapon(Entity, slot : number)
	local weapon = Entity.Weapons[slot]
	if weapon ~= nil then
		weapon:Destroy()
	end
end
return WeaponHelper

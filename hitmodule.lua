local HitModule = {}

local EntityModule = require(game.ReplicatedStorage.Modules.Entity)

function HitModule.hit(source : Instance, target: Instance, dmg : number, force : number)
	-->> Block of Checks
	if target:IsA("BasePart") then target = target:FindFirstAncestorWhichIsA("Model") end
	local hum : Humanoid = target:FindFirstChild("Humanoid", true)
	if not hum then warn("Cannot damage something without health / humanoid") return false end
	local entity = EntityModule.getEntityFromModel(target)
	if source == entity then warn("Cannot damage oneself?") return false end
	--<<
	
	-->> Check if Target Entity being attacked is holding a weapon
	local isHoldingWeapon = entity.EquippedSlot ~= 0 and entity.EquippedSlot ~= nil
	local weaponCanBlock = isHoldingWeapon and entity.Weapons[entity.EquippedSlot].isBlocking ~= nil
	
	-->> If holding a weapon and entity is blocking  
	-->>-->> Nullify damage and damage stamina
	if weaponCanBlock and entity.Weapons[entity.EquippedSlot].isBlocking then
		local defense = entity.Statistics.Defense or 0
		local staminaDamageAmount = math.clamp(dmg - defense, 0, math.huge)/100
		dmg = 0
		
		-->> Does entity have stamina
		if entity.Stamina ~= nil then
			entity:SpendStamina(staminaDamageAmount)
		end
	end
	
	if entity then
		entity:Damage(dmg)
	else
		return false
	end
	
	return true
end

return HitModule

local DamageModule = {}

local RE_indicator = game.ReplicatedStorage.Events:WaitForChild("DamageIndicator")

local EntityModule = require(game.ReplicatedStorage.Modules.Entity)

function DamageModule.damage(source, target : Instance, dmg)
	if target:IsA("BasePart") then target = target:FindFirstAncestorWhichIsA("Model") end
	local hum : Humanoid = target:FindFirstChild("Humanoid", true)
	if not hum then warn("Cannot damage something without health / humanoid") return false end
	
	local entity = EntityModule.getEntityFromModel(target)
	
	if source == entity then warn("Cannot damage oneself?") return false end
	
	if entity then
		print("Found entity: ")
		print(entity)
		entity:Damage(dmg)
	else
		return false
	end
	
	return true
end

return DamageModule

local WeldHandler = {}

local defaultGrip = "Right Arm"

function WeldHandler.createGrip(Weapon, Entity, grip)
	local handle: Motor6D = Instance.new("Motor6D", grip)
	handle.Name = "HandleGrip"
	handle.Part0 = Entity.Model:FindFirstChild(grip:GetAttribute("desiredGripParent") or defaultGrip) or Entity.Model:FindFirstChild(defaultGrip)
	handle.Part1 = grip
	handle.C0 = grip.HandlePosition.CFrame
	return handle
end

function WeldHandler.createUnequippedHandle(Entity, grip)
	local handleUnequipped: Weld = Instance.new("Weld", grip)
	handleUnequipped.Part0 = Entity.Model.Torso
	handleUnequipped.Part1 = grip
	return handleUnequipped
end

function WeldHandler.getUnequippedCFrame(Weapon)
	local cfname = "Unequipped".. Weapon.slot
	local unequippedCFrame: CFrameValue = Weapon.model.Attachments:FindFirstChild(cfname) or Weapon.Model:FindFirstChild("Unequipped")
	if not unequippedCFrame then warn("Warning: "..Weapon.name.." unequipped position not set yet") return end
	return unequippedCFrame.Value
end

return WeldHandler

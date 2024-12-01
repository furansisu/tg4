local PhysicsMaster = {}

local LinearVelocities = {}

local raycastParams = RaycastParams.new()
raycastParams.RespectCanCollide = true

function PhysicsMaster.ApplyLinearVelocity(entity, speed : number, seconds : number, direction : Vector3)
	
	local primaryPart = entity.Model.PrimaryPart
	
	local vel: LinearVelocity = primaryPart:FindFirstChild("LinearVelocity") or primaryPart:FindFirstChild("DashVelocity")
	if not vel then
		local attachment = primaryPart:FindFirstChildOfClass("Attachment")
		vel = Instance.new("LinearVelocity", primaryPart)
		vel.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
		vel.Attachment0 = attachment
		vel.MaxForce = math.huge
	end
	
	if not direction then
		direction = primaryPart.CFrame.LookVector
	end
	
	vel.LineVelocity = speed
	vel.LineDirection = direction
	vel.Enabled = true
	
	local timeStart = tick()
	
	
	
	
	LinearVelocities[vel] = {
		timeStart = timeStart,
		timePeriod = seconds,
		direction = direction,
		model = entity.Model
	}
end

function decelerate(lv : LinearVelocity, deltaTime : number, timeStart : number, timePeriod : number)
	local targetDeceleration = 120

	-- Once the time period of dashing at max speed ends, start deceleration
	if tick() - timeStart > timePeriod then
		if lv.LineVelocity - targetDeceleration * deltaTime <= 0 then
			lv.LineVelocity = 0
			lv.Enabled = false
			LinearVelocities[lv] = nil
			return
		end
		lv.LineVelocity -= targetDeceleration * deltaTime
	end
end

game["Run Service"].Stepped:Connect(function(t, deltaTime)
	if next(LinearVelocities) ~= nil then
		for vel : LinearVelocity, velData in pairs(LinearVelocities) do
			if velData.model then
				local primaryPart = velData.model.PrimaryPart
				if not primaryPart then continue end
				raycastParams.FilterDescendantsInstances = {velData.model}
				local result = workspace:Raycast(primaryPart.Position, velData.direction * 1.5, raycastParams)
				if result then
					warn("Warning: "..velData.model.Name.." is trying to line velocity itself into something. Slowing down")
					vel.LineVelocity *= 0.1 * deltaTime
				end
			end
			decelerate(vel, deltaTime, velData.timeStart, velData.timePeriod)
		end
	end
end)

return PhysicsMaster

local Body = {}
Body.__index = Body

function Body.new(Entity)
	-->> ASSIGN THE VARIABLES
	-- bools
	Entity.Ragdolled = false
	Entity.Stilled = false

	Entity.Walkspeed = Entity.Model.Humanoid.Walkspeed
	Entity.TaskStill = nil

	-->> GIVE THE ENTITY THE FUNCTIONS
	Entity.Still = Body.Still
	Entity.Unstill = Body.Unstill
	Entity.Interrupt = Body.Interrupt
	Entity.Knockback = Body.Knockback
end

-->> self IS STILL ENTITY

--- Makes the entity stop walking / moving for given amount of time (seconds)
function Body:Still(seconds : number)
	-- when the player gets damaged, does an attack, stunned, etc
	self.Stilled = true
	self.Model.Humanoid.Walkspeed = 0
	self.TaskStill = task.delay(seconds, function()
		self.Model.Humanoid.Walkspeed = self.Walkspeed
		self.Stilled = false
	end)
end

function Body:Unstill()
	if self.Stilled then
		self.Model.Humanoid.Walkspeed = self.Walkspeed
		self.Stilled = false
		if self.TaskStill then
			task.cancel(self.TaskStill)
		end
	end
end

--- Interrupts current entity's action
function Body:Interrupt()
	-- stop all anims except Idle

	local animator = self.Model:FindFirstChild("Animator", true)
	if animator then
		local tracks = animator:GetPlayingAnimationTracks()

		for _, track in pairs(tracks) do
			if track.Name ~= "Idle" then
				track:Stop()
			end
		end
	end

	--[[ other things this should do:
	> drop what the entity is carrying
	> stop any skill being casted
	]]
end

local function stopAttack(self)
	local animationTrack = AnimationHandler.getPlayingAnimation(self, "Attack".. self.attackAnimInfo.lastAttackAnim)
	self.animations["Attack".. self.attackAnimInfo.lastAttackAnim]:Stop()
	if animationTrack then
		animationTrack:Stop()
	end
	for index, connection in pairs(self.attackAnimInfo.Connections) do
		if connection then
			connection:Disconnect()
		end
	end
	if self.attackAnimInfo.walkSpeedDelayTask then
		task.cancel(self.attackAnimInfo.walkSpeedDelayTask)
	end
	self.holder.Model.Humanoid.WalkSpeed = self.attackAnimInfo.originalWalkSpeed
	stopHitDetection(self)
end

return Health

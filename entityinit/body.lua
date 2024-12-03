local Body = {}
Body.__index = Body

function Body.new(Entity)
	print("Creating BODY component")
	-->> ASSIGN THE VARIABLES
	-- bools
	Entity.Ragdolled = false
	Entity.Stilled = false

	Entity.WalkSpeed = Entity.Model.Humanoid.WalkSpeed
	Entity.TaskStill = nil

	-->> GIVE THE ENTITY THE FUNCTIONS
	Entity.Still = Body.Still
	Entity.Unstill = Body.Unstill
	Entity.Interrupt = Body.Interrupt
	--Entity.Knockback = Body.Knockback
end

-->> self IS STILL ENTITY

--- Makes the entity stop walking / moving for given amount of time (seconds)
function Body:Still(seconds : number)
	-- when the player gets damaged, does an attack, stunned, etc
	
	self.Stilled = true
	self.Model.Humanoid.WalkSpeed = 0
	if self.TaskStill then task.cancel(self.TaskStill) end
	if seconds ~= 0 then
		self.TaskStill = task.delay(seconds, function()
			self.Model.Humanoid.WalkSpeed = self.WalkSpeed
			self.Stilled = false
		end)
	end
end

function Body:Unstill()
	if self.Stilled then
		self.Model.Humanoid.WalkSpeed = self.WalkSpeed
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
			if string.find(track.Name, "Idle") == nil then
				print("Stopping track: "..track.Name)
				track:Stop()
			end
		end
	end
	if self.EquippedSlot ~= 0 then
		print("Interrupting actions on weapon too")
		self.Weapons[self.EquippedSlot]:InterruptAction()
	end

	--[[ other things this should do:
	> drop what the entity is carrying
	> stop any skill being casted
	]]
end

return Body

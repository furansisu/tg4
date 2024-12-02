local PhysicsMaster = require(game.ReplicatedStorage.Modules.PhysicsMaster)
local RaycastHitbox = require(game.ReplicatedStorage.Modules.RaycastHitboxV4)
local DamageModule = require(game.ReplicatedStorage.Modules.DamageModule)

local AnimationHandler = require(game.ReplicatedStorage.Modules.BaseWeapon.AnimationHandler)
local SoundHandler = require(game.ReplicatedStorage.Modules.BaseWeapon.SoundHandler)
local WeldHandler = require(game.ReplicatedStorage.Modules.BaseWeapon.WeldHandler)

local function getRandomAttackNumber(self)
	return ((self.attackAnimInfo.lastAttackAnim) % self.attackAnimInfo.numberOfAttackAnims) + 1
end

local function startHitDetection(self, attack)
	self.hitbox:HitStart()
	if self.trail then
		self.trail.Enabled = true
	end

	self.sounds["Attack"..attack]:Play()
end

local function stopHitDetection(self)
	self.hitbox:HitStop()
	if self.trail then
		self.trail.Enabled = false
	end
end

local function resetPlayerSpeed(self)
	self.holder.Model.Humanoid.WalkSpeed = self.attackAnimInfo.originalWalkSpeed 
end

local function stunPlayerSpeed(self)
	self.holder.Model.Humanoid.WalkSpeed = 0
	self.attackAnimInfo.walkSpeedDelayTask = task.delay(0.5, resetPlayerSpeed, self)
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
	self.holder.Model.Humanoid.WalkSpeed = self.attackAnimInfo.originalWalkSpeed
	stopHitDetection(self)
end

local Katana = {}

function Katana:loadSelfData()
	self.clickDelay = 0.5
	self.attackAnimInfo = {
		numberOfAttackAnims = 2,
		lastAttackAnim = 1,
		lastAttackTime = 0,
		Connections = {},
	}
	self.blockAnimInfo = {
		lastBlockStartTime = 0,
		lastBlockEndTime = 0,
		isBlocking = false,
	}
	
	---->> HITBOX PARTY
	self.hitbox = RaycastHitbox.new(self.model)

	self.hitbox.OnHit:Connect(function(hit, humanoid)
		if hit:FindFirstAncestorOfClass("Model") == self.holder.Model then return end
		if DamageModule.damage(self.holder, hit, 32) then
			self.sounds["Hit"]:Play()
		end	
	end)

	self.trail = self.model:FindFirstChild("Trail", true)
	----<<

	---->> WELD PARTY
	local grip = self.model:FindFirstChild("Grip")
	self.handleWeld = WeldHandler.createGrip(self, self.holder, grip)
	self.handleUnequipped = WeldHandler.createUnequippedHandle(self.holder, grip)
	self.handleUnequipped.C1 = WeldHandler.getUnequippedCFrame(self)
	----<<
end

function Katana:PrimaryClick()
	if (not self.equipped) or (tick() - self.attackAnimInfo.lastAttackTime < self.clickDelay) then return end

	local attack = getRandomAttackNumber(self)
	self.attackAnimInfo.lastAttackAnim = attack
	self.animations["Attack".. attack]:Play()

	local animationTrack = AnimationHandler.getPlayingAnimation(self, "Attack".. attack)
	self.attackAnimInfo.originalWalkSpeed = 16--self.holder.Model.Humanoid.WalkSpeed
	stunPlayerSpeed(self)

	self.attackAnimInfo.Connections["startHit"] = animationTrack:GetMarkerReachedSignal("hit"):Once(function()
		startHitDetection(self, attack)
	end)
	self.attackAnimInfo.Connections["endHit"] = animationTrack:GetMarkerReachedSignal("end"):Once(function()
		stopHitDetection(self)
	end)


	PhysicsMaster.ApplyLinearVelocity(self.holder, 20, 0.1)
	self.attackAnimInfo.lastAttackTime = tick()
end

function Katana:SecondaryDown()
	if (not self.equipped) or self.blockAnimInfo.isBlocking then return end
	stopAttack(self)
	
	self.blockAnimInfo.isBlocking = true
	
	self.animations["BlockIntro"]:Play()
	self.animations["BlockIdle"]:Play()
	
	self.attackAnimInfo.originalWalkSpeed = self.holder.Model.Humanoid.WalkSpeed
	self.holder.Model.Humanoid.WalkSpeed = 0
	
	self.sounds["IntroBlockSound"]:Play()
	
	self.blockAnimInfo.lastBlockStartTime = tick()
end

function Katana:SecondaryUp()
	if (not self.equipped) or not self.blockAnimInfo.isBlocking then return end
	self.blockAnimInfo.isBlocking = false
	
	self.animations["BlockIntro"]:Stop()
	self.animations["BlockIdle"]:Stop()
	
	self.holder.Model.Humanoid.WalkSpeed = self.attackAnimInfo.originalWalkSpeed
	
	self.blockAnimInfo.lastBlockEndTime = tick()
end

return Katana

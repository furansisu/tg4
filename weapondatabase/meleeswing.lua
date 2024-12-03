local PhysicsMaster = require(game.ReplicatedStorage.Modules.PhysicsMaster)
local RaycastHitbox = require(game.ReplicatedStorage.Modules.RaycastHitboxV4)
local DamageModule = require(game.ReplicatedStorage.Modules.DamageModule)

local AnimationHandler = require(game.ReplicatedStorage.Modules.BaseWeapon.AnimationHandler)
local SoundHandler = require(game.ReplicatedStorage.Modules.BaseWeapon.SoundHandler)
local WeldHandler = require(game.ReplicatedStorage.Modules.BaseWeapon.WeldHandler)
local Signal = require(game.ReplicatedStorage.Modules.Signal)

local function getRandomAttackNumber(self)
	return ((self.attackAnimInfo.lastAttackAnim) % self.attackAnimInfo.numberOfAttackAnims) + 1
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
	self.holder:Unstill()
	self:StopHitDetection()
end

local MeleeSwing = {}

function MeleeSwing:Reset()
	self.attackAnimInfo = {
		numberOfAttackAnims = 2,
		lastAttackAnim = 1,
		lastAttackTime = 0,
		Connections = {},
	}
end

function MeleeSwing:loadSelfData()
	self.clickDelay = 0.5
	MeleeSwing.Reset(self)
	
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
end

---------------------------------------------------------------------------------------------------

function MeleeSwing:PrimaryClick()
	if (not self.equipped) or (tick() - self.attackAnimInfo.lastAttackTime < self.clickDelay) then return end

	self:InterruptAction()
	
	self.holder:Still(0.5)

	local attack = getRandomAttackNumber(self)
	self.attackAnimInfo.lastAttackAnim = attack
	self.animations["Attack".. attack]:Play()

	local animationTrack = AnimationHandler.getPlayingAnimation(self, "Attack".. attack)
	
	self.attackAnimInfo.Connections["startHit"] = animationTrack:GetMarkerReachedSignal("hit"):Once(function()
		if self.trail then
			self.trail.Enabled = true
		end

		self.sounds["Attack"..attack]:Play()
		self:StartHitDetection()
	end)
	self.attackAnimInfo.Connections["endHit"] = animationTrack:GetMarkerReachedSignal("end"):Once(function()
		if self.trail then
			self.trail.Enabled = false
		end
		self:StopHitDetection()
	end)
	
	PhysicsMaster.ApplyLinearVelocity(self.holder, 20, 0.1)
	self.attackAnimInfo.lastAttackTime = tick()
end

return MeleeSwing

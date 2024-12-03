local PhysicsMaster = require(game.ReplicatedStorage.Modules.PhysicsMaster)
local RaycastHitbox = require(game.ReplicatedStorage.Modules.RaycastHitboxV4)
local DamageModule = require(game.ReplicatedStorage.Modules.DamageModule)

local AnimationHandler = require(game.ReplicatedStorage.Modules.BaseWeapon.AnimationHandler)
local SoundHandler = require(game.ReplicatedStorage.Modules.BaseWeapon.SoundHandler)
local WeldHandler = require(game.ReplicatedStorage.Modules.BaseWeapon.WeldHandler)
local Signal = require(game.ReplicatedStorage.Modules.Signal)

local MeleeBlock = {}

function MeleeBlock:Reset()
	StopBlock(self)
	self.isBlocking = false
	self.blockAnimInfo = {
		lastBlockStartTime = 0,
		lastBlockEndTime = 0,
	}
end

function MeleeBlock:loadSelfData()
	self.clickDelay = 0.5
	MeleeBlock.Reset(self)
	
	self.interrupted:subscribe(function(stringArg)
		if stringArg == "Dont stop block" then return end --idk
		StopBlock(self)
	end)
end

---------------------------------------------------------------------------------------------------

function StartBlock(self)
	if (not self.equipped) or self.isBlocking or self.buffer or self.blockCD then return end

	self.buffer = true
	self.blockCD = true
	self.holder:Interrupt("Dont stop block")

	self.isBlocking = true

	self.holder:Still(0)

	self.animations["BlockIntro"]:Play()
	self.animations["BlockIdle"]:Play()
	self.sounds["IntroBlockSound"]:Play()

	self.blockAnimInfo.lastBlockStartTime = tick()
	print("Last block start time: "..self.blockAnimInfo.lastBlockStartTime)
	task.wait(0.2)
	self.buffer = false

	--- hard coded. fix later
	task.wait(0.3)
	self.blockCD = false
end

function StopBlock(self)
	if (not self.equipped) or not self.isBlocking then return end

	if self.buffer then
		print("Waiting a bit..")
		wait(0.2)
	end
	self.isBlocking = false

	self.animations["BlockIntro"]:Stop()
	self.animations["BlockIdle"]:Stop()
	print("Animations stopped")

	self.holder:Unstill()
	print("Got HERE")

	self.blockAnimInfo.lastBlockEndTime = tick()
	print("Last block end time: "..self.blockAnimInfo.lastBlockEndTime)
end

function MeleeBlock:SecondaryDown()
	print("Secondary down")
	StartBlock(self)
end

function MeleeBlock:SecondaryUp()
	print("Secondary up")
	StopBlock(self)
end

return MeleeBlock

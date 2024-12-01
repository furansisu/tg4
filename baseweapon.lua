local BaseWeapon = {}
BaseWeapon.__index = BaseWeapon

-- MODULES
local PhysicsMaster = require(game.ReplicatedStorage.Modules.PhysicsMaster)
local RaycastHitbox = require(game.ReplicatedStorage.Modules.RaycastHitboxV4)
local DamageModule = require(game.ReplicatedStorage.Modules.DamageModule)

local InputHandler = require(script.InputHandler)
local AnimationHandler = require(script.AnimationHandler)
local SoundHandler = require(script.SoundHandler)
local WeldHandler = require(script.WeldHandler)

local WeaponDatabase = require(game.ReplicatedStorage.Databases.WeaponDatabase)

-- VARIABLES
local ReplStorage = game:GetService("ReplicatedStorage")
local Events = ReplStorage:WaitForChild("Events")


-- CONFIG

function BaseWeapon.new(model: Model)
	local self = setmetatable({}, BaseWeapon)

	self.model = model:Clone()
	self.name = model.Name
	self.holder = nil
	self.equipped = false
	self.stats = model:FindFirstChild("Info")               -- folder	
	SoundHandler.initializeSounds(self)
	self.slot = 0

	local events_folder = Instance.new("Folder", model)
	events_folder.Name = "Events"
	
	return self
end

function BaseWeapon:GiveTo(Entity: Entity, slot : number)
	self.holder = Entity
	self.model.Parent = self.holder.Model
	
	if not self.holder.Weapons[slot] then
		self.holder.Weapons[slot] = self
	else
		error("Weapon ".. self.name.. " cannot be given to ".. Entity.name.. "; slot ".. slot.. " is occupied")
	end
	
	self.slot = slot
	
	WeaponDatabase.ApplyDataToWeapon(self)
	
	print(self.name .. " given to " .. Entity.Name)
	
	---->> DEFINING SOME VARIABLES
	self.animations = {}
	
	---->> INPUT PARTY
	InputHandler.controlInput(self)
	----<<<
	
	---->> ANIMATION PARTY
	AnimationHandler.initializeAnimations(self)
	----<<
	
	------------------------------ ITS TIME TO PARTY SHUT THE PUCK UP
	self.ready = true
	return true
end

function BaseWeapon:Equip()
	if self.equipped == true then return end
	if not self.holder then 
		warn(self.name .. " couldn't be equipped: No holder") 
		return
	end
	
	print("Equipped")
	self.equipped = true
	self.animations["Equip"]:Play()
	self.animations["IdleLoop"]:Play()
	
	-- do weld stuff
	self.handleWeld.Enabled = true
	self.handleUnequipped.Enabled = false
	
	self.sounds["Equip"]:Play()
end

function BaseWeapon:Unequip()
	if self.equipped == false then return end
	if not self.holder then
		warn(self.name .. " couldn't be unequipped: No holder")
		return
	end
	
	for _, anim in self.animations do
		anim:Stop()
	end
	self.handleWeld.Enabled = false
	self.handleUnequipped.Enabled = true
	self.equipped = false
	
	self.sounds["Unequip"]:Play()
end

--------------------------------------------------------------------------

function BaseWeapon:PrimaryClick()                          -- left click
	print("Primary click")
end

function BaseWeapon:PrimaryDown()
	print("Primary held down")
end

function BaseWeapon:PrimaryUp()
	print("Primary released")
end



function BaseWeapon:SecondaryClick()                        -- right click
	print("Secondary click")
end

function BaseWeapon:SecondaryDown()
	print("Secondary held down")
end

function BaseWeapon:SecondaryUp()
	print("Secondary released")
end



function BaseWeapon:TertiaryClick()                              -- R key
	print("Tertiary click")
end

function BaseWeapon:TertiaryDown()
	print("Tertiary held down")
end

function BaseWeapon:TertiaryUp()
	print("Tertiary released")
end

function BaseWeapon:Destroy()
	self:Unequip()
	self.model:Destroy()
	self = nil
end

return BaseWeapon
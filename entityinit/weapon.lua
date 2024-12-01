local ReplStorage = game:GetService("ReplicatedStorage")
local Events = ReplStorage:WaitForChild("Events")

local Weapon = {}
Weapon.__index = Weapon

-->> DEFAULT VALUES


function Weapon.new(Entity)
	-->> ASSIGN THE VARIABLES
	Entity.Weapons = {}
	Entity.EquippedSlot = 0
	
	-->> GIVE THE ENTITY THE FUNCTIONS
	Entity.HoldWeapon = Weapon.HoldWeapon
	Entity.SwitchWeapon = Weapon.SwitchWeapon
	Entity.HolsterWeapon = Weapon.HolsterWeapon
	
	-->> GIVE THE ENTITY THE EVENTS
	local newEventsFolder = script.Events:Clone()
	newEventsFolder.Parent = Entity.Model
	
	-->> CONNECT SWITCH INPUT FROM THE ENTITY
	local Events = Entity.Model:WaitForChild("Events")
	Events.RE_switch.Event:Connect(function()
		Entity:SwitchWeapon()
	end)
	Events.RE_holster.Event:Connect(function()
		Entity:HolsterWeapon()
	end)
end

function Weapon:HoldWeapon(Slot: number)
	local currentWeapon = self.Weapons[self.EquippedSlot]
	local nextWeapon = self.Weapons[Slot]
	
	if not nextWeapon then return end
	
	if currentWeapon then
		currentWeapon:Unequip()
	end
	self.EquippedSlot = Slot
	nextWeapon:Equip()
end

function Weapon:SwitchWeapon()
	local otherSlot = if self.EquippedSlot == 1 then 2 else 1
	if self.Weapons[otherSlot] then
		self:HoldWeapon(otherSlot)
	elseif self.Weapons[2] then
		self:HoldWeapon(2)
	end
end

function Weapon:HolsterWeapon()
	local currentWeapon = self.Weapons[self.EquippedSlot]
	if not currentWeapon then return end
	currentWeapon:Unequip()
	
	self.EquippedSlot = 0
end

return Weapon

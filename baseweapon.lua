local BaseWeapon = {}
BaseWeapon.__index = BaseWeapon

-- VARIABLES
local ReplStorage = game:GetService("ReplicatedStorage")
local Events = ReplStorage:WaitForChild("Events")
local loadWeaponAnimation, playWeaponAnimation = Events:WaitForChild("loadWeaponAnimation"), Events:WaitForChild("playWeaponAnimation")

-- CONFIG
hold_threshold = 0.2 --time it takes when holding down a button before it is not considered a click anymore

function BaseWeapon.new(model: Model)
	local self = setmetatable({}, BaseWeapon)

	self.model = model:Clone()
	self.name = model.Name
	self.holder = nil
	self.equipped = false
	self.stats = model:FindFirstChild("Info")               -- folder
	self.sounds = model:FindFirstChild("Sounds")

	local events_folder = Instance.new("Folder", model)
	events_folder.Name = "Events"

	return self
end

function BaseWeapon:GiveTo(player: Player)
	if player then
		self.holder = player
		self.model.Parent = player.Character
		
		print(self.name .. " given to " .. player.Name)
		
		local RE_primary = player.Character.Events:FindFirstChild("RE_primary")
		local RE_secondary = player.Character.Events:FindFirstChild("RE_secondary")
		local RE_tertiary = player.Character.Events:FindFirstChild("RE_tertiary")
		
		self.primary_hold_time = 0
		self.primary_connection = RE_primary.OnServerEvent:Connect(function(player : Player, inputState : Enum.UserInputState)
			if not self.equipped then return end
			if inputState == Enum.UserInputState.Begin then
				self:PrimaryDown()
				self.primary_hold_time = tick()
			elseif inputState == Enum.UserInputState.End then
				local hold_duration = tick() - self.primary_hold_time
				if hold_duration < hold_threshold then
					self:PrimaryClick() 
				end
				self:PrimaryUp()
			end
		end)

		self.secondary_hold_time = 0
		self.secondary_connection = RE_secondary.OnServerEvent:Connect(function(player : Player, inputState : Enum.UserInputState)
			if not self.equipped then return end
			if inputState == Enum.UserInputState.Begin then
				self:SecondaryDown()
				self.secondary_hold_time = tick()
			elseif inputState == Enum.UserInputState.End then
				local hold_duration = tick() - self.secondary_hold_time
				if hold_duration < hold_threshold then
					self:SecondaryClick() 
				end
				self:SecondaryUp()
			end
		end)

		self.tertiary_hold_time = 0
		self.tertiary_connection = RE_tertiary.OnServerEvent:Connect(function(player : Player, inputState : Enum.UserInputState)
			if not self.equipped then return end
			if inputState == Enum.UserInputState.Begin then
				self:TertiaryDown()
				self.tertiary_hold_time = tick()
			elseif inputState == Enum.UserInputState.End then
				local hold_duration = tick() - self.tertiary_hold_time
				if hold_duration < hold_threshold then
					self:TertiaryClick() 
				end
				self:TertiaryUp()
			end
		end)
		
		self.animations = {}

		self.attackAnimInfo = {
			numberOfAttackAnims = 0,
			lastAttackAnim = 0
		}

		local grip = self.model:FindFirstChild("Grip")
		local handle : Motor6D = Instance.new("Motor6D", grip)
		handle.Part0 = player.Character.Torso
		handle.Part1 = grip
		print("Created weld")
		
		loadWeaponAnimation:FireClient(self.holder, self.name, self.model:FindFirstChild("Animations"):GetChildren())
		
		local animator : Animator = player.Character:FindFirstChild("Animator", true)
		for _, anim : Animation in self.model:FindFirstChild("Animations"):GetDescendants() do
			if anim:IsA("Animation") then
				local animTable
				if string.find(anim.Name, "Attack") ~= nil then
					self.attackAnimInfo.numberOfAttackAnims += 1
				end
				self.animations[anim.Name] = {
					Play = function(animations, fadeTime: number, weight: number, speed: number)
						playWeaponAnimation:FireClient(self.holder, self.name, anim.Name, fadeTime, weight, speed)
					end,
					Track = anim
				}
				print("Set anim: "..anim.Name)
			end
		end
		
		local event : RemoteEvent = player.Character.Events:WaitForChild("WeaponEvent")
		event:FireClient(player, true)
		return true
	else
		return false
	end
end

function BaseWeapon:Equip()
	if not self.holder then 
		warn(self.name .. " couldn't be equipped: No holder") 
		return
	end
	
	print("Equipped")
	self.equipped = true
	self.animations["Equip"]:Play()
	self.animations["IdleLoop"]:Play()
	
	-- do weld stuff
end

function BaseWeapon:Unequip()
	if not self.holder then
		warn(self.name .. " couldn't be unequipped: No holder")
		return
	end
	
	self.animations["IdleLoop"]:Stop()
	self.equipped = false
	-- do more weld stuff
end

function BaseWeapon:PrimaryClick()                          -- left click
	local attack = 0
	repeat
		attack = math.random(1,self.attackAnimInfo.numberOfAttackAnims)
	until attack ~= self.attackAnimInfo.lastAttackAnim
	
	self.attackAnimInfo.lastAttackAnim = attack

	self.animations["Attack"..attack]:Play()
	self.animations["Attack"..attack].Anim
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
	self.model:Destroy()
	self = nil
end

return BaseWeapon
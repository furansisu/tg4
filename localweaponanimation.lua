-- REFERENCES
local ReplStorage = game:GetService("ReplicatedStorage")
local Events = ReplStorage:WaitForChild("Events")
local Players = game:GetService("Players")

-- CHARACTER and PLAYER
local Player = Players.LocalPlayer
local Character = Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Instance.new("Animator", Humanoid)

-- REMOTE EVENT
local loadWeaponAnimation = Events:WaitForChild("loadWeaponAnimation")
local playWeaponAnimation = Events:WaitForChild("playWeaponAnimation")
local stopWeaponAnimation = Events:WaitForChild("stopWeaponAnimation")

-- TABLE VARIABLE
local loadedAnimations = {}

local function onLoadWeaponAnim(weaponName: string, animations: Folder)
	loadedAnimations[weaponName] = {}
	for _, AnimationObj in pairs(animations) do
		loadedAnimations[weaponName][AnimationObj.name] = Animator:LoadAnimation(AnimationObj)
	end
	print("LOADED WEAPON ANIMATIONS: ")
	print(loadedAnimations[weaponName])
end

local function onPlayWeaponAnim(weaponName: string, animationName: string, ...: animationParameters)
	if not loadedAnimations[weaponName] then
		warn("WEAPON ".. weaponName.. " NOT LOADED")
		return
	elseif not loadedAnimations[weaponName][animationName] then
		warn(weaponName.. "'S ANIMATION ".. animationName.. " NOT LOADED")
		return
	end
	loadedAnimations[weaponName][animationName]:Play(...)
end

local function onStopWeaponAnim(weaponName: string, animationName: string)
	if not loadedAnimations[weaponName] then
		warn("WEAPON ".. weaponName.. " NOT LOADED")
		return
	elseif not loadedAnimations[weaponName][animationName] then
		warn(weaponName.. "'S ANIMATION ".. animationName.. " NOT LOADED")
		return
	end
	loadedAnimations[weaponName][animationName]:Stop()
end

local function onCharacterRemoved()
	loadedAnimations = {}
end

local function onCharacterAdded(newCharacter)
	Character = newCharacter
	Humanoid = Character:WaitForChild("Humanoid")
	Animator = Instance.new("Animator", Humanoid)
	
	local OldAnimator = Humanoid:WaitForChild("Animator")

	-- local animator?
	OldAnimator:Destroy()
end

loadWeaponAnimation.OnClientEvent:Connect(onLoadWeaponAnim)
playWeaponAnimation.OnClientEvent:Connect(onPlayWeaponAnim)
stopWeaponAnimation.OnClientEvent:Connect(onStopWeaponAnim)
Player.CharacterRemoving:Connect(onCharacterRemoved)
Player.CharacterAdded:Connect(onCharacterAdded)
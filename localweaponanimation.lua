-- REFERENCES
local ReplStorage = game:GetService("ReplicatedStorage")
local Events = ReplStorage:WaitForChild("Events")
local Players = game:GetService("Players")

-- CHARACTER and PLAYER
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
local Animator: Animator = Humanoid:WaitForChild("Animator")

-- REMOTE EVENT
local loadWeaponAnimation = Events:WaitForChild("loadWeaponAnimation")
local playWeaponAnimation = Events:WaitForChild("playWeaponAnimation")

-- TABLE VARIABLE
local loadedAnimations = {}

local function onLoadWeaponAnim(weaponName: string, animations: {Animation})
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
	elseif not loadedAnimations[weaponName][animationName] then
		warn(weaponName.. "'S ANIMATION ".. animationName.. " NOT LOADED")
	end
	loadedAnimations[weaponName][animationName]:Play(...)
end

loadWeaponAnimation.OnClientEvent:Connect(onLoadWeaponAnim)
playWeaponAnimation.OnClientEvent:Connect(onPlayWeaponAnim)
-- VARIABLES
local ReplStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Events = ReplStorage:WaitForChild("Events")
local Modules = ReplStorage:WaitForChild("Modules")

-- MODULES
local Ping = require(ServerScriptService:WaitForChild("Ping"))

-- EVENTS
local loadWeaponAnimation = Events:WaitForChild("loadWeaponAnimation")
local playWeaponAnimation = Events:WaitForChild("playWeaponAnimation")
local stopWeaponAnimation = Events:WaitForChild("stopWeaponAnimation")

local AnimationHandler = {}

function AnimationHandler.initializeAnimations(Weapon)
	local Animations = Weapon.model:FindFirstChild("Animations"):GetChildren()
	local animator : Animator = Weapon.holder.Model:FindFirstChild("Animator", true)
	
	
	local isPlayer = Weapon.holder.Player ~= nil
	if isPlayer then
		loadWeaponAnimation:FireClient(Weapon.holder.Player, Weapon.name, Animations)
	end
	
	for _, animation: Animation in pairs(Animations) do
		local track: AnimationTrack
		track = animator:LoadAnimation(animation)
		
		Weapon.animations[animation.Name] = {
			Play = function(animations, ...)
				if isPlayer then
					playWeaponAnimation:FireClient(Weapon.holder.Player, Weapon.name, animation.Name, ...)
				end
				track:Play(...)
			end,
			Stop = function(animations, ...)
				if isPlayer then
					stopWeaponAnimation:FireClient(Weapon.holder.Player, Weapon.name, animation.Name, ...)
				end
				track:Stop(...)
				
				-->> HUH?
				if next(Weapon.hitbox) ~= nil then
					Weapon.hitbox:HitStop()
				end
				--<<
			end,
			Track = track
		}
		print("Set anim: ".. animation.Name)
	end
end

local function attemptAnimationFetch(Animator, ANIMATION_ID)
	for _, Animation in pairs(Animator:GetPlayingAnimationTracks()) do
		if Animation.Animation.AnimationId == ANIMATION_ID then
			return Animation
		end
	end
end

function AnimationHandler.getPlayingAnimation(Weapon, name: string) -- ASSUMING PLAYER HELD WEAPON
	-->> GET ANIMATION ID
	local ANIMATION_ID = ""
	
	local Animations = Weapon.model:FindFirstChild("Animations"):GetChildren()
	for _, Animation in pairs(Animations) do
		if Animation.Name == name then
			ANIMATION_ID = Animation.AnimationId
			break
		end
	end
	--<<
	
	-->> MATCH ANIMATION ID WITH ALL PLAYING ANIMATIONS
	local Animator = Weapon.holder.Model.Humanoid.Animator
	
	local AnimationTrack: AnimationTrack = attemptAnimationFetch(Animator, ANIMATION_ID)
	if not AnimationTrack then
		-->> WAIT FOR PING
		task.wait(Ping.getPlayerPing(Weapon.holder) * 1.1)
		--<< TRY AGAIN
		AnimationTrack = attemptAnimationFetch(Animator, ANIMATION_ID)
	end
	--<<
	
	if not AnimationTrack then
		warn("FAILED TO FETCH ANIMATION TRACK: "..name)
	end
	
	return AnimationTrack
end

return AnimationHandler

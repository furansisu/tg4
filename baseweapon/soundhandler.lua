local SoundHandler = {}

function SoundHandler.initializeSounds(Weapon)
	
	local Sounds = Weapon.model:FindFirstChild("Sounds", true):GetChildren()
	Weapon.sounds = {}
	for _, sound : Sound in pairs(Sounds) do
		Weapon.sounds[sound.Name] = {
			Play = function()
				local fakeSound = sound:Clone()
				fakeSound.Parent = Weapon.model.PrimaryPart
				fakeSound.PlayOnRemove = true
				fakeSound:Destroy()
			end,
			Sound = sound,
		}
	end
end

return SoundHandler

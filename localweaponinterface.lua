-- CLIENT
local plr = game:GetService("Players").LocalPlayer
local cas = game:GetService("ContextActionService")

local RE_primary : RemoteEvent = nil
local RE_secondary : RemoteEvent = nil
local RE_tertiary : RemoteEvent= nil

function Primary(actionName : string, inputState : Enum.UserInputState, inputObject : InputObject)
	if not RE_primary then
		RE_primary = plr.Character.Events:FindFirstChild("RE_primary")
	end
	
	RE_primary:FireServer(inputState)
end

function Secondary(actionName : string, inputState : Enum.UserInputState, inputObject : InputObject)
	if not RE_secondary then
		RE_secondary = plr.Character.Events:FindFirstChild("RE_secondary")
	end
	
	RE_secondary:FireServer(inputState)
end

function Tertiary(actionName : string, inputState : Enum.UserInputState, inputObject : InputObject)
	if not RE_tertiary then
		RE_tertiary = plr.Character.Events:FindFirstChild("RE_tertiary")
	end
	
	RE_tertiary:FireServer(inputState)
end

function EnableWeaponInterface()
	cas:BindAction("Primary", Primary, true, Enum.UserInputType.MouseButton1)
	cas:BindAction("Secondary", Secondary, true, Enum.KeyCode.E)
	cas:BindAction("Tertiary", Tertiary, true, Enum.KeyCode.R)
end

function DisableWeaponInterface()
	cas:UnbindAction("Primary")
	cas:UnbindAction("Secondary")
	cas:UnbindAction("Tertiary")
end

local WeaponEquippedEvent : RemoteEvent = plr.Character.Events:WaitForChild("WeaponEvent")

WeaponEquippedEvent.OnClientEvent:Connect(function(hasWeapon)
	if hasWeapon then
		print("Player has a weapon")
		EnableWeaponInterface()
	else
		DisableWeaponInterface()
	end
end)
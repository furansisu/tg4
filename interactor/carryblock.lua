local RunService = game:GetService("RunService")
local ReplStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Blocks = workspace:WaitForChild("Blocks")

local Events = ReplStorage:WaitForChild("Events")
local Modules = ReplStorage:WaitForChild("Modules")

local module = {}
module.currentBlock = nil
module.blockIndicator = nil

-- MODULES
local BlockPlacementChecker = require(Modules:WaitForChild("BlockPlacementChecker"))
--

---- LOCAL VARIABLES
local HighlightIndicator = script:WaitForChild("Highlight")

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = {Blocks}

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {Character, Blocks}

local placementCFrame = CFrame.new()

local carryAnimation: AnimationTrack = Character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(script:WaitForChild("Carry"))
--

---- LOCAL FUNCTIONS

local function getBlockInfront()
	-- Find Parts under Blocks infront of the player
	local PartsInFront = workspace:GetPartBoundsInBox(Character:GetPivot() + Character:GetPivot().LookVector * 4, Vector3.new(4, 4, 4), overlapParams)

	-- Filter Parts to the Closest Part infront
	local ClosestPart: BasePart
	for _, Part in pairs(PartsInFront) do
		if not ClosestPart or (Part.Position - Character.PrimaryPart.Position).Magnitude < (ClosestPart.Position - Character.PrimaryPart.Position).Magnitude then
			ClosestPart = Part
		end
	end
	
	if not ClosestPart then
		return false
	end
	
	-- Get Block Model
	return ClosestPart:FindFirstAncestorOfClass("Model")
end

local function getPositionToBottom(Position: Vector3)
	local ray = workspace:Raycast(Position, Vector3.new(0, -20, 0), raycastParams)
	if ray then
		return ray.Position
	else
		return Position
	end
end

local function createIndicator()
	module.blockIndicator = module.currentBlock:Clone()
	HighlightIndicator.Parent = module.blockIndicator
	HighlightIndicator.Enabled = true
	HighlightIndicator.Adornee = module.blockIndicator
	Instance.new("Humanoid", module.blockIndicator)
	
	-- INCASE BLOCK HAS HEALTH GUI -- DESTROY
	local HealthGUI: BillboardGui | nil = module.blockIndicator.PrimaryPart:FindFirstChild("HealthGUI")
	if HealthGUI then
		HealthGUI:Destroy()
	end
end

local function hideBlockIndicator()
	for _, Part: BasePart in pairs(module.blockIndicator:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part.Transparency = .99
			Part.CanCollide = false
			Part.CanQuery = false
			Part.CanTouch = false
			Part.Anchored = true
		end
	end
end

local function destroyIndicator()
	HighlightIndicator.Enabled = false
	HighlightIndicator.Adornee = nil
	HighlightIndicator.Parent = script

	if module.blockIndicator then
		module.blockIndicator:Destroy()
		module.blockIndicator = nil
	end
end

local function getPlacementCFrame()
	local cFrameInFront = Character:GetPivot() + Character:GetPivot().LookVector * 4
	local bottomPosition = getPositionToBottom(cFrameInFront.Position) + (Vector3.yAxis * module.currentBlock:GetExtentsSize().Y/2)
	return CFrame.lookAt(bottomPosition, bottomPosition - Character:GetPivot().LookVector)
end

----

---- MAIN FUNCTIONS

function module.CarryBlock(actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
	if inputState ~= Enum.UserInputState.Begin then return end
	
	if not module.currentBlock then
		module.currentBlock = getBlockInfront()
		
		-- Ask server to place ontop of head
		local Result = Events.CarryBlockRequest:InvokeServer(module.currentBlock)
		if not Result then
			warn"Failed to carry block!"
			module.currentBlock = nil
			return
		end
		
		-- Play Animation
		carryAnimation:Play()
	else
		
		local Result = Events.PlacementBlockRequest:InvokeServer(module.currentBlock, placementCFrame)
		if not Result then
			warn"Failed to place block!"
			return
		end
		
		module.currentBlock = nil
		
		-- Stop Animation
		carryAnimation:Stop()
	end
end

----

-- RENDER STEP UPDATER
if Player and Character then
	local function onRenderStep(deltaTime: number)
		if not module.currentBlock then 
			destroyIndicator()
			return 
		end
		
		if not module.blockIndicator then
			createIndicator()
			hideBlockIndicator()
		end
		
		-- Get Placement CFrame of Block Infront
		placementCFrame = getPlacementCFrame()
		module.blockIndicator:PivotTo(placementCFrame)
		module.blockIndicator.Parent = workspace
		
		-- Check if placement is valid
		local isValid = BlockPlacementChecker.isBlockPositionValid(module.currentBlock, placementCFrame)
		if isValid then
			HighlightIndicator.OutlineColor = Color3.new(0, 1, 0)
		else
			HighlightIndicator.OutlineColor = Color3.new(1, 0, 0)
		end
	end
	RunService.RenderStepped:Connect(onRenderStep)
end

return module

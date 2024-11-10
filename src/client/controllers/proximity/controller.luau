local proximityPromptService = game:GetService("ProximityPromptService")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")

local knit = require("@packages/knit")
local janitor = require("@packages/janitor")

local player = players.LocalPlayer

local promptTemplate = script.Parent:WaitForChild("prompt")

local controller = knit.CreateController({
	Name = "PromptController",
})

function createPrompt(prompt)
	local promptUi = promptTemplate:Clone()
	-- local expand = promptUi:WaitForChild("Expand")
	local interactionFrame = promptUi:WaitForChild("Interaction")
	local interactionContainer = interactionFrame:WaitForChild("Container")
	local descriptions = interactionContainer:WaitForChild("Descriptions")
	local key = interactionContainer:WaitForChild("Key")
	local progress = key:WaitForChild("Progress")
	local object = descriptions:WaitForChild("Object")
	local typeK = descriptions:WaitForChild("Type")

	typeK.Text = prompt.ActionText
	object.Text = prompt.ObjectText

	local inTween = tweenService:Create(
		interactionFrame.UIScale,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	)

	local holdingTween = tweenService:Create(
		progress.UIScale,
		TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear),
		{ Scale = 1 }
	)

	--[[
	local forceTween = tweenService:Create(
		progress.UIScale,
		TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true),
		{ Scale = 1 }
	)]]

	local connections = {}

	connections[#connections + 1] = prompt.PromptButtonHoldBegan:Connect(function()
		if prompt.HoldDuration > 0 then
			holdingTween:Play()
		end

		if prompt.Parent:HasTag("Reader") then
			local targetPosition = (prompt.Parent.CFrame * CFrame.new(2.25, -0.6, 1.5)).p
			local humanoid = player.Character.Humanoid

			humanoid:MoveTo(targetPosition, prompt.Parent)
		end
	end)

	connections[#connections + 1] = prompt.PromptButtonHoldEnded:Connect(function()
		if prompt.HoldDuration > 0 then
			holdingTween:Cancel()
			progress.UIScale.Scale = 0
		end

		if prompt.Parent:HasTag("Reader") then
			player.Character:MoveTo(player.Character.PrimaryPart.CFrame.p)
		end
	end)

	connections[#connections + 1] = prompt.Triggered:Connect(function()
		if prompt.Parent:HasTag("Reader") then
			local targetPosition = (prompt.Parent.CFrame * CFrame.new(2.25, -0.6, 1.5)).p

			player.Character.HumanoidRootPart.CFrame =
				CFrame.new(targetPosition, (prompt.Parent.CFrame * CFrame.new(0, 0, 1.5)).p)
		end
	end)

	--[[connections[#connections + 1] = prompt.Triggered:Connect(function()
		if prompt.HoldDuration == 0 then
			forceTween:Play()
		end

		task.spawn(function()
			local expandC = expand:Clone()
			expandC.Parent = promptUi
			expandC.Visible = true

			tweenService:Create(expandC, TweenInfo.new(1), { BackgroundTransparency = 1 }):Play()
			tweenService:Create(expandC.UIScale, TweenInfo.new(1), { Scale = 1.75 }):Play()

			task.delay(1, function()
				expandC:Destroy()
			end)
		end)
	end)]]

	connections[#connections + 1] = prompt:GetPropertyChangedSignal("ActionText"):Connect(function()
		typeK.Text = prompt.ActionText
	end)

	promptUi.Parent = prompt.Parent
	promptUi.Adornee = prompt.Parent

	inTween:Play()

	return function()
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end

		promptUi:Destroy()
	end
end

function promptShown(prompt: ProximityPrompt)
	assert(prompt, "You must specify a valid prompt for ProximityController:TogglePrompt")

	if prompt.Style == Enum.ProximityPromptStyle.Default then
		return
	end

	local cleanup = createPrompt(prompt)

	prompt.PromptHidden:Wait()

	cleanup()
end

function controller:KnitInit()
	self.Janitor = janitor.new()
	self.Janitor:Add(proximityPromptService.PromptShown:Connect(promptShown))
end

return controller

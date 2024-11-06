local roact = require("@packages/roact")

local debounce = false

return roact.createElement("TextButton", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.4, 0.1),
	Text = "click this button and be happy",
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.5,

	[roact.Event.MouseButton1Click] = function(element)
		if not debounce then
			debounce = true
			local tween = game.TweenService:Create(
				element.UIScale,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true),
				{ Scale = 0.9 }
			)

			tween:Play()
			tween.Completed:Wait()
			debounce = false
		end
	end,
}, {
	UIScale = roact.createElement("UIScale"),
	UICorner = roact.createElement("UICorner"),
	UIStroke = roact.createElement("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Color3.fromRGB(255, 255, 255),
	}, {
		UIGradient = roact.createElement("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.7, 1),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Rotation = -90,
		}),
	}),
})

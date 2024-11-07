local roact = require("@packages/roact")

return roact.createElement("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.5,
	Size = UDim2.fromScale(0.5, 0.15),
	Position = UDim2.fromScale(0.5, 0.5),
	ZIndex = 2,
}, {
	UICorner = roact.createElement("UICorner", {
		CornerRadius = UDim.new(0.1, 0),
	}),
	UIGradient = roact.createElement("UIGradient", {
		Transparency = NumberSequence.new(0, 1),
	}),
	UIStroke = roact.createElement("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
	}, {
		UIGradient = roact.createElement("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.7, 1),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}),
	}),

	Container = roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0.8),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 3,
	}, {
		--[[
		UIListLayout = roact.createElement("UIListLayout", {
			Padding = UDim.new(0.05, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		}),]]

		Key = roact.createElement("CanvasGroup", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.7,
			Size = UDim2.fromScale(0.3, 1),
			Position = UDim2.fromScale(0.14, 0.5),
			ZIndex = 4,
		}, {
			UICorner = roact.createElement("UICorner", {
				CornerRadius = UDim.new(0.1, 0),
			}),
			UIStroke = roact.createElement("UIStroke", {
				Color = Color3.fromRGB(126, 126, 126),
			}, {
				UIGradient = roact.createElement("UIGradient", {
					Rotation = 50,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.5, 1),
						NumberSequenceKeypoint.new(1, 0),
					}),
				}),
			}),
			UIScale = roact.createElement("UIScale", {}),

			Progress = roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.85,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0, 0), -- 0, 0
				ZIndex = 5,
			}, {
				UICorner = roact.createElement("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),

			Input = roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Text = "E", -- Default input text (E)
				Font = Enum.Font.Sarpanch,
				TextColor3 = Color3.fromRGB(214, 214, 214),
				TextSize = 100, -- Max text size
				ZIndex = 6,
			}),
		}),

		Descriptions = roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.67, 0.5),
			Size = UDim2.fromScale(0.67, 1),
			BackgroundTransparency = 1,
			ZIndex = 4,
		}, {
			UIListLayout = roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),

			Type = roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0.5),
				Text = "Interact",
				Font = Enum.Font.Sarpanch,
				TextColor3 = Color3.fromRGB(214, 214, 214),
				TextScaled = true,
				TextTransparency = 0.49,
			}),
		}),
	}),
})

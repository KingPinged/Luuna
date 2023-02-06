local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local e = React.createElement

local buttonProps = {
	{
		text = "Play",
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("628c70")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("90b870")),
		}),
	},
	{
		text = "Credits",
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("90b870")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("bfd4b0")),
		}),
	},
	{
		text = "Help",
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("bfd4b0")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("628c70")),
		}),
	},
}

return function()
	local toggle, setToggle = React.useState(false)

	local springProps = {}
	for i in ipairs(buttonProps) do
		table.insert(springProps, {
			position = UDim2.fromScale(if toggle then 0.45 else 0.35, 0.05 + i * 0.25),
			transparency = if toggle then 0 else 1,
			config = { damping = 1, frequency = 0.3 },
		})
	end
	local springs = RoactSpring.useTrail(#buttonProps, springProps)

	React.useEffect(function()
		task.wait(1)
		setToggle(true)
	end, {})

	local buttons = {}

	for index, buttonProp in ipairs(buttonProps) do
		buttons[index] = e("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = springs[index].position,
			Transparency = springs[index].transparency,
			Size = UDim2.fromScale(1, 0.13),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			AutoButtonColor = false,
		}, {
			UICorner = e("UICorner"),
			UIGradient = e("UIGradient", {
				Color = buttonProp.gradient,
			}),
			UIStroke = e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(95, 95, 95),
				Thickness = 2,
				Transparency = springs[index].transparency,
			}, {
				UIGradient = e("UIGradient", {
					Rotation = -90,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.85),
						NumberSequenceKeypoint.new(1, 1),
					}),
				}),
			}),
			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.5, 0.7),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Text = buttonProp.text,
				TextSize = 22,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = springs[index].ZIndex,
				TextTransparency = springs[index].transparency,
			}),
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(-0.05, 0.5),
		Size = UDim2.fromScale(0.3, 0.6),
	}, {}, buttons)
	-- return e("Frame", {
	-- 	AnchorPoint = Vector2.new(0.5, 0.5),
	-- 	Position = UDim2.fromScale(0.5, 0.5),
	-- 	Size = UDim2.fromScale(0.3, 0.7),
	-- 	BackgroundTransparency = 1,
	-- }, buttons)
end

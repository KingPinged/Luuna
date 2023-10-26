--[[
Functionality:
	- Creates 3 buttons on MENU

TODO:
	- Link button to separate activation functions
	-- align buttons center Y
]]
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local Scaler = require(ReplicatedStorage.gui.scaler)

local e = React.createElement

local GUI_Y = 0.3

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

return function(props)
	--local finishedSlideIn, setFinishedSlideIn = React.useState(false)
	--local lastButton = React.useRef(nil)

	local springs, api = RoactSpring.useTrail(#buttonProps, function(i)
		return {
			--i * 0.25 is EXACTLY next to it (0.25 is the height of the button?)
			position = UDim2.fromScale(-0.2, 0.05 + i * 0.25),
			transparency = 1,
			config = { damping = 1, frequency = 0.3, mass = 1, tension = 810, friction = 20 },
		}
	end)

	React.useEffect(function()
		if not props.logoFinish then
			return
		end

		api.start(function(i)
			return {
				position = UDim2.fromScale(0, 0.05 + i * GUI_Y),
				transparency = 0,
			}
		end):andThen(function()
			--setFinishedSlideIn(true)
		end)

		--setToggle(true)
	end)

	local buttons = {}

	for index, buttonProp in ipairs(buttonProps) do
		buttons[index] = e("ImageButton", {
			Name = buttonProp.text,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = springs[index].position,
			Transparency = springs[index].transparency,
			Size = UDim2.fromScale(1, 0.25),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			AutoButtonColor = false,
			[React.Event.Activated] = function() end,
			[React.Event.MouseEnter] = function(_)
				--lastButton.current = index

				--if finishedSlideIn then
				api.start(function(i)
					if i == index then
						return {
							position = UDim2.fromScale(0.2, 0.05 + i * GUI_Y),
							ZIndex = 10,
						}
					end
					return {
						position = UDim2.fromScale(0.0, 0.05 + i * GUI_Y),
						ZIndex = 10,
					}
				end)
				--end
			end,
			[React.Event.MouseLeave] = function(_)
				--if finishedSlideIn then
				api.start(function(i)
					if i == index then
						return {
							position = UDim2.fromScale(0, 0.05 + i * GUI_Y),
							ZIndex = 10,
						}
					end
					return nil
				end)
				--end
			end,
		}, {
			Scaler = e(Scaler, { Size = Vector2.new(150, 150), Scale = 0.2 }),
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

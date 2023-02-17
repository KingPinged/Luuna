local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local Players = game:GetService("Players")

local e = React.createElement

--The tablist will have the following groups: Players, Info

--TODO: allow list to dynamically update based on player join and leave
function PlayerTrail(props)
	local length: number = #props.players

	local springProps = {}
	for index, item in ipairs(props.players) do
		table.insert(springProps, {
			from = { transparency = 1 },
			to = { transparency = 0 },
			config = { mass = 1, tension = 1000, friction = 20 },
		})
	end

	local springs: boolean = ReactSpring.useTrail(length, springProps)

	local contents = {}
	for i: number, v in ipairs(props.players) do
		contents[i] = e("TextLabel", {
			TextTransparency = springs[i].transparency,
			Text = `•{v.Name}`,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromScale(1, 0.1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			TextScaled = true,
		})
	end
	return contents
end

return function(props)
	local finishedAnimation, setFinishedAnimation = React.useState(props.finishedAnimation or false)
	local players, setPlayers = React.useState(Players:GetPlayers())

	React.useEffect(function()
		local connection = Players.PlayerAdded:Connect(function()
			setPlayers(Players:GetPlayers())
		end)

		return function()
			connection:Disconnect()
		end
	end)

	local styles, api = ReactSpring.useSpring(function()
		return {
			BackgroundTransparency = 1,
			size = UDim2.fromScale(0.8, 0),
		}
	end)

	React.useEffect(function()
		api.start(function()
			return {
				BackgroundTransparency = 0.6,
				size = UDim2.fromScale(0.8, 0.85),
				config = {
					tension = 700,
					precision = 0.04,
				},
			}
		end):andThen(function()
			setFinishedAnimation(true)
		end)

		return function()
			api.stop()
		end
	end)

	return e("Frame", {
		BackgroundTransparency = styles.BackgroundTransparency,
		Size = styles.size,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	}, {
		finishedAnimation and (e("Frame", {
			Name = "ContentBox",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.9, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}, {

			e("Frame", {
				Name = "PlayerBox",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.1, 1),
			}, {
				Label = e("TextLabel", {
					Text = `Players ({#players})`,
					AnchorPoint = Vector2.new(0, 1),
					Size = UDim2.fromScale(1, 0.1),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.5,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				}, { UiCorner = e("UICorner", {
					CornerRadius = UDim.new(0.25, 0),
				}) }),
				PlayerTrailContainer = e("Frame", {
					Name = "PlayerBox",
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.fromScale(0.9, 0.9),
				}, {
					PlayerTrail = e(PlayerTrail, { players = players }),
					UiList = e("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
				}),
			}),
			e("Frame", {
				Name = "InfoBox",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.2, 1),
				Position = UDim2.fromScale(0.2, 0),
			}, {
				Label = e("TextLabel", {
					Text = "Info",
					AnchorPoint = Vector2.new(0, 1),
					Size = UDim2.fromScale(1, 0.1),
					BorderSizePixel = 0,
					BackgroundTransparency = 0.5,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}, { UiCorner = e("UICorner", {
					CornerRadius = UDim.new(0.25, 0),
				}) }),
				PlayerTrailContainer = e("Frame", {
					Name = "PlayerBox",
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.fromScale(0.9, 0.9),
				}, {
					PlayerTrail = e(PlayerTrail, { players = players }),
					UiList = e("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
				}),
			}),
		})),
	})
end

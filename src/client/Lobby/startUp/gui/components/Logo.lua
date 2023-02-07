local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local Scaler = require(ReplicatedStorage.ui.Scaler)

local e = React.createElement

return function(props)
	local finishedPosition, setFinishedPosition = React.useState(false)

	local styles, api = RoactSpring.useSpring(function()
		return {
			position = UDim2.fromScale(0.5, 0),
			config = { mass = 1, tension = 180, friction = 12 },
			default = true,
		}
	end)

	local sizeStyle = RoactSpring.useSpring({
		size = if finishedPosition then UDim2.fromScale(0.55, 0.45) else UDim2.fromScale(0.5, 0.4),
		loop = true,
		config = { mass = 50, clamp = true },
		-- to = { size = UDim2.fromScale(0.6, 0.5) },
		-- loop = { reset = true },
	})

	local rotateStyle = RoactSpring.useSpring({
		rotation = if finishedPosition then 5 else -5,
		loop = true,
		config = { mass = 40, tension = 210, friction = 20, precision = 0.01 },
		-- to = { size = UDim2.fromScale(0.6, 0.5) },
		-- loop = { reset = true },
	})

	React.useEffect(function()
		task.wait(1)

		api.start({ position = UDim2.fromScale(0.5, 0.4), config = { precision = 0.001 } }):andThen(function()
			task.wait(0.5)
			print("Logo now finished")

			api.stop()

			setFinishedPosition(true)

			props.setLogoFinish(true)
		end)
	end)

	return e("ImageLabel", {
		Image = "rbxassetid://12406363023",
		ScaleType = Enum.ScaleType.Fit,
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		Position = styles.position,
		Size = sizeStyle.size,
		Rotation = if finishedPosition then rotateStyle.rotation else 0,
	})
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local Scaler = require(ReplicatedStorage.ui.Scaler)

local e = React.createElement

return function(props)
	local styles, api = RoactSpring.useSpring(function()
		return {
			position = UDim2.fromScale(0.5, 0),
			config = { mass = 1, tension = 180, friction = 12 },
			default = true,
		}
	end)

	React.useEffect(function()
		task.wait(1)

		api.start({ position = UDim2.fromScale(0.5, 0.4) }):andThen(function()
			task.wait(0.5)
			print("Logo now finished")
			props.setLogoFinish(true)
		end)
	end)

	return e("ImageLabel", {
		Image = "rbxassetid://12406363023",
		ScaleType = Enum.ScaleType.Fit,
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		Position = styles.position,
		Size = UDim2.fromScale(0.5, 0.4),
	})
end

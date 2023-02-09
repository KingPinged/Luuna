local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local e = Roact.createElement

return function(props)

    local finishedAnimation, setFinishedAnimation = React.useState(props.finishedAnimation or false)

    local styles, api = RoactSpring.useSpring(function()
        return {
            BackgroundTransparency = 1,
            size = Udim2.new(0.8,0),
        }
    })
    

	React.useEffect(function()
		api.start(function(i)
			return {
                BackgroundTransparency = 0.5,
                size = Udim2.new(0.8,0.85),
			}
		end):andThen(function()
			setFinishedAnimation(true)
		end)

	end)


	return e("Frame", {
		BackgroundTransparency = styles.BackgroundTransparency,
		Size = styles.size,
		AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0.5),
	},{
        finishedAnimation and (e("TextLabel", {
            Text = "Finished",
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255,255,255),
            TextScaled = true,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0,0,0),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
    })
end

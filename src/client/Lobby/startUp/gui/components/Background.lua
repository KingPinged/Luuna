local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local e = Roact.createElement

return function()
	local styles = RoactSpring.useSpring({
		from = { position = UDim2.new(0, 0, 0, 0) },
		to = { position = UDim2.new(-1, 0, -1, 0) },
		loop = true,
		config = { duration = 15 },
	})

	return e("Frame", {
		BackgroundColor3 = Color3.fromRGB(127, 155, 176),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.fromScale(2, 2),
		Position = styles.position,
	}, {
		pattern = Roact.createElement("ImageLabel", {
			Image = "rbxassetid://121480522",
			ImageColor3 = Color3.fromRGB(104, 104, 135),
			ImageTransparency = 0.2,
			ScaleType = Enum.ScaleType.Tile,
			SliceCenter = Rect.new(0, 256, 0, 256),
			TileSize = UDim2.fromOffset(50, 50),
			BackgroundColor3 = Color3.fromRGB(104, 104, 135),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 9,
		}),
	})
end

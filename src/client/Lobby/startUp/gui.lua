local a = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

function a:start(player)
	print("creating startup gui")
	local root = Roact.createElement("ScreenGui", {
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		frame = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(127, 155, 176),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.fromScale(1, 1),
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
		}),
	})

	Roact.mount(root, player.PlayerGui, "startUpGui")
end

return a

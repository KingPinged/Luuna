local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera

local TopInset, BottomInset = GuiService:GetGuiInset()

local Roact = require(ReplicatedStorage.Packages.React)

local e = Roact.createElement

--TODO optimization needs to be watched in this function
return function(props)
	local scaleState, setScaleState = Roact.useState({
		Scale = 1,
	})
	local currentSize = props.Size

	Roact.useEffect(function()
		local viewportSize = Camera.ViewportSize - (TopInset + BottomInset)

		setScaleState({
			Scale = 1 / math.max(currentSize.X / viewportSize.X, currentSize.Y / viewportSize.Y),
		})

		local listener = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			print("ViewportSize changed")

			viewportSize = Camera.ViewportSize - (TopInset + BottomInset)

			setScaleState({
				Scale = 1 / math.max(currentSize.X / viewportSize.X, currentSize.Y / viewportSize.Y),
			})
		end)

		return function()
			listener:Disconnect()
		end
	end)

	return e("UIScale", {
		Scale = scaleState.Scale * props.Scale,
	})
end

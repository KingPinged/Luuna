local a = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Roact = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local e = Roact.createElement

local Background = require(script.components.Background)

local function CircleButton(props)
	return e("TextButton", {
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		Size = props.Size or UDim2.fromOffset(150, 150),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		Text = "",

		[Roact.Event.Activated] = props[Roact.Event.Activated],
		[Roact.Event.InputBegan] = props[Roact.Event.InputBegan],
		[Roact.Event.InputEnded] = props[Roact.Event.InputEnded],
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		UIGradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 255, 183)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 119, 253)),
			}),
			Rotation = 25,
		}),
	})
end

local function Button()
	local styles, api = RoactSpring.useSpring(function()
		return {
			size = UDim2.fromOffset(150, 150),
			position = UDim2.fromScale(0.5, 0.5),
			config = { tension = 100, friction = 10 },
		}
	end)
	local connection = Roact.useRef()

	return e(CircleButton, {
		Position = styles.position,
		Size = styles.size,

		[Roact.Event.InputBegan] = function(_, input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				if not connection.value then
					connection.value = RunService.Heartbeat:Connect(function()
						local mousePos = UserInputService:GetMouseLocation()
							- Vector2.new(0, GuiService:GetGuiInset().Y)

						api.start({
							position = UDim2.fromOffset(mousePos.X, mousePos.Y),
							size = UDim2.fromOffset(180, 180),
						})
					end)
				end
			end
		end,
		[Roact.Event.InputEnded] = function(_, input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				if connection.value then
					api.start({ size = UDim2.fromOffset(150, 150) })
					connection.value:Disconnect()
					connection.value = nil
				end
			end
		end,
	})
end

function a:start(player)
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(ReactRoblox.createPortal({
		App = e("ScreenGui", { IgnoreGuiInset = true }, { buttonChild = e(Button), background = e(Background) }),
	}, player.PlayerGui))
end

return a

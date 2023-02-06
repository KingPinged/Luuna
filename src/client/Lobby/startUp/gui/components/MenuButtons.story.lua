local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local e = Roact.createElement

local MenuButtons = require(script.parent.MenuButtons)

return function(target)
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(ReactRoblox.createPortal({
		App = e(MenuButtons),
	}, target))

	return function()
		root:unmount()
	end
end

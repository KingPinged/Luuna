--[[
Functionality:
Handles changing and accessing keybinds of the player's choise
Will not work in non keyboard environment.

Theres two approaches that I can think of for this:

1. Have a single key event to check if key pressed is a keybind
2. Have events for each key function be tied to changes to keybind code

TODO:


]]
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local config = require(ReplicatedStorage.Packages)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyBindController = Knit.CreateController({ Name = "KeyBindController" })

local keybinds = require(ReplicatedStorage:FindFirstChild("config")).defaultKeybinds or {}

function KeyBindController:KnitStart()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
end

--The server when the player's data is procesed, will fire this function
function KeyBindController.onGetKeybinds(keys)
	keybinds = keys
end

--when setting new keybind, call this function

function KeyBindController:waitForKey(promise)
	local key
	local inputEvent

	inputEvent = UIS.InputBegan:Connect(function(input)
		if table.find(config.bannedKeys, input.KeyCode) then
			return
		end

		key = input.KeyCode
	end)

	--! TODO: check this syntax
	promise:Once():Wait()

	inputEvent:Disconnect()
end

--outside calling this to get the keybinds
function KeyBindController:getKey(keybind)
	if keybind == nil then
		return keybinds
	end

	return keybinds[keybind]
end

return KeyBindController

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = require(ReplicatedStorage:WaitForChild("config"))

Knit.AddControllers(script.Parent:WaitForChild("SharedClient").controllers)

if game.PlaceId == config.lobbyPlaceId then
	Knit.AddServices(script.Parent.Lobby.services)
end
Knit.AddServices(script.Parent.SharedServer.services)

Knit.Start():catch(warn)

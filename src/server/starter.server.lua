local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = require(ReplicatedStorage:WaitForChild("config"))

if game.PlaceId == config.lobbyPlaceId then
	Knit.AddServices(script.Parent.Lobby.services)
else game.PlaceId == config.gamePlaceId then
	Knit.AddControllers(script.parent.Game.controllers)
end
Knit.AddServices(script.Parent.SharedServer.services)

Knit.Start():catch(warn)

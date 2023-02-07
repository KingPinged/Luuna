local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local config = require(ReplicatedStorage:WaitForChild("config"))

Knit.AddControllers(script.Parent:WaitForChild("SharedClient").controllers)

if game.PlaceId == config.lobbyPlaceId then
	Knit.AddControllers(script.Parent.Lobby.controllers)
elseif game.PlaceId == config.gamePlaceId then
	Knit.AddControllers(script.parent.Game.controllers)
end

Knit.Start():catch(warn)

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = require(ReplicatedStorage:WaitForChild("config"))

if game.PlaceId == config.lobbyPlaceId then
	Knit.AddServices(script.Parent.Parent.Parent.Lobby.services)
elseif game.PlaceId == config.gamePlaceId then
	Knit.AddControllers(script.parent.Game.controllers)
end
Knit.AddServices(script.Parent.Parent.services)

Knit.Start():catch(warn)

return function()
	local LogService = Knit.GetService("LogService")

	describe("logService", function()
		it("should give correct syntax for log", function()
			local message = LogService:Log("test", "ServerLog", "test", true)
			expect(message).to.equal("[test|ServerLog|v({config.version})]: test")
		end)
	end)
end

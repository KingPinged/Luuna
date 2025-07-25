local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxTeleportService = game:GetService("TeleportService")

local config = require(ReplicatedStorage.config)

local Promise = require(ReplicatedStorage.Packages.Promise)

local Knit = require(ReplicatedStorage.Packages.Knit)

local LogService

local TeleportService = Knit.CreateService({
	Name = "TeleportService",
	Client = {
		playerTeleported = Knit.CreateSignal(),
	},
})

function TeleportService:TeleportPlayer(player)
	Promise.retry(
		Promise.new(function(resolve, reject)
			local success, result = pcall(function()
				return RobloxTeleportService:TeleportAsync(config.gamePlaceId, { player })
			end)

			if not success then
				reject(result)
			else
				resolve(result)
			end
		end),
		config.maxTeleportTries
	)
		:andThen(function(result)
			LogService:Log(
				player,
				`Player {player.Name} teleported successfully: {result}`,
				"ServerLog",
				"TeleportService",
				true
			)
		end)
		:catch(function(err)
			LogService:Log(
				player,
				`Player {player.Name} failed to teleport: {err}`,
				"ServerError",
				"TeleportService",
				true
			)
		end)
end

function TeleportService:KnitStart()
	LogService = Knit.GetService("LogService")
end

function TeleportService:KnitInit()
	self.Client.playerTeleported:Connect(function(player)
		self:TeleportPlayer(player)
	end)
end

return TeleportService

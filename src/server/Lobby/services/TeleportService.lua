local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxTeleportService = game:GetService("TeleportService")

local config = require(ReplicatedStorage.config)

local Promise = require(ReplicatedStorage.Packages.Promise)

local Knit = require(ReplicatedStorage.Packages.Knit)

local TeleportService = Knit.CreateService({
	Name = "TeleportService",
	Client = {
		playerTeleported = Knit.CreateSignal(),
	},
})

function TeleportService:TeleportPlayer(player)
	Promise.retry(
		Promise.new(function(resolve, reject)
			-- do something that can fail

			local success, result = pcall(function()
				return RobloxTeleportService:TeleportAsync(config.gamePLaceId, { player })
			end)

			if not success then
				warn("Teleport failed: " .. result)
				reject(result)
			else
				resolve(result)
			end
		end),
		config.maxTeleportTries
	)
end

function TeleportService:KnitStart() end

function TeleportService:KnitInit()
	self.Client.playerTeleported:Connect(function(player)
		print(`{player.Name} teleport request`)
		self:TeleportPlayer(player)
	end)
end

return TeleportService

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local TeleportService = Knit.CreateService({
	Name = "TeleportService",
	Client = {},
})

function TeleportService:KnitStart() end

function TeleportService:KnitInit() end

return TeleportService

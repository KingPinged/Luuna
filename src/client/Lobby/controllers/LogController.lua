local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local LogController = Knit.CreateController({ Name = "LogController" })

local GameAnalytics = require(ReplicatedStorage.Packages.GameAnalytics)

function LogController:KnitStart()
	GameAnalytics:initClient()
end

function LogController:KnitInit() end

return LogController

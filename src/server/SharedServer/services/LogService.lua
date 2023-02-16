--* This service is responsible for logging and analytics

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local config = require(ReplicatedStorage.config)

local Promise = require(ReplicatedStorage.Packages.Promise)
local EnumList = require(ReplicatedStorage.Packages.EnumList)
local GameAnalytics = require(ReplicatedStorage.Packages.GameAnalytics)

local LogService = Knit.CreateService({
	Name = "LogService",
	Client = {},
})

local levelList = EnumList.new("Level", {
	"ServerLog",
	"ClientLog",
	"ServerError",
	"ClientError",
})

--At the moment... no analytics server. Hoping for playfab release

local logs = {} -- ALL logs are stored here

function LogService:Log(player: Player, message: string, level : string, origin : string, shouldWarn : boolean))
	if not levelList.BelongsTo(level) then
		return
	end

	local logContent = `[{origin}|{level}|v({config.version})]: {message}`
	logs[os.time()] = logContent

	if shouldWarn then
		warn(logContent)
	end

	GameAnalytics:addErrorEvent((player and player.UserId) or "server", {
		severity = if level == levelList.ServerError or level == levelList.ClientError
			then GameAnalytics.EGAErrorSeverity.error
			else GameAnalytics.EGAErrorSeverity.info,
		message = logContent,
	})

	return logContent

	--TODO send to analytics server
end

function LogService:GetLogHistory(fromTime, toTime)
	if not fromTime then
		fromTime = 0
	end
	if not toTime then
		toTime = os.time()
	end
	local logHistory = {}
	for time, message in pairs(logs) do
		if time >= fromTime and time <= toTime then
			logHistory[time] = message
		end
	end

	return logHistory
end

function LogService:KnitStart()
	GameAnalytics:configureBuild(config.version)
	GameAnalytics:setEnabledInfoLog(true)
	GameAnalytics:setEnabledVerboseLog(true)
	GameAnalytics:initServer("f7d2d1a65adb0823f22b8c1e6f738586", "4e21ec6d38d7a19bf6d6a41680698b5be4941302")

	game:BindToClose(function()
		LogService:Log(nil, "Server closed", levelList.ServerLog, "LogService")
	end)
end

function LogService:KnitInit() end

return LogService

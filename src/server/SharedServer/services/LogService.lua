local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local config = require(ReplicatedStorage.config)

local EnumList = require(ReplicatedStorage.Packages.EnumList)

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

function LogService:Log(message, level)
	if not levelList.BelongsTo(level) then
		return
	end
	logs[os.time()] = `[{level}|v({config.version})]: {message}`

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

function LogService:KnitStart() end

function LogService:KnitInit() end

return LogService

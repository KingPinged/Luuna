local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ModeratorService = Knit.CreateService({
	Name = "ModeratorService",
	Client = {},
})

local config = require(ReplicatedStorage.config)

local banList = {}

local Promise = require(ReplicatedStorage.Packages.Promise)
local Timer = require(ReplicatedStorage.Packages.Timer)

local DataService
local LogService

--do not make direct method of service to prevent potential abuse / all banning must be handled HERE
function BanPlayer(player) end

function ModeratorService:KickPlayer(player, reason)
	--todo: add a delay between each try
	Promise.retry(
		Promise.new(function(resolve, reject)
			local success, result = pcall(function()
				return player:Kick(reason or "No reason given")
			end)

			if not success then
				warn(`Failed to kick {player.Name} : {result} `)
				reject(result)
			else
				resolve(result)
			end
		end),
		config.maxModerationTries
	)
end

--this is also called in PlayerService every 60 seconds
function ModeratorService:CheckPlayerModerated(player)
	--this may not be as performant as just checking a dictionary key if banList becomes too big
	for _, v in banList do
		if v == player.UserId then
			self:KickPlayer(player)
		end
	end

	local playerData = DataService:GetDataOfPlayer(player)

	if playerData then
		if playerData.banData.isBanned then
			if os.time() < playerData.banData.banEndTime then
				--the question is, can Player:Kick() even error?
				Promise.new(function(resolve, reject, onCancel)
					self:KickPlayer(
						player,
						`You are banned until {playerData.banData.banEndTime} due to {playerData.banData.banReason}`
					)
					resolve("Kicked")
				end)
					:andThen(function()
						LogService:Log(
							player,
							`Player {player.Name} has been kicked by ban. Banned until {playerData.banData.banEndTime} due to {playerData.banData.banReason}`,
							"ServerLog",
							"ModeratorService"
						)
					end)
					:catch(function(err)
						LogService:Log(
							player,
							`Failed to kick player {player.Name} due to {err}`,
							"ServerError",
							"ModeratorService"
						)
					end)
			else
				--TODO unban player and change Database entry

				LogService:Log(
					player,
					`Player {player.Name} has been unbanned. Expired at {playerData.banData.banEndTime} from {playerData.banData.banReason}`,
					"ServerLog",
					"ModeratorService"
				)
			end
		end
	else
		LogService:Log(player, `Player {player.Name} has no data entry`, "ServerError", "ModeratorService")
	end
end

function ModeratorService.Client:CheckPlayerModerated(player)
	return self.Server:CheckPlayerModerated(player)
end

function ModeratorService:KnitStart()
	LogService = Knit.GetService("LogService")
	DataService = Knit.GetService("DataService")
end

return ModeratorService

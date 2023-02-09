local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local LogService

local Concur = require(ReplicatedStorage.Packages.Concur)
local ProfileService = require(ReplicatedStorage.Packages.ProfileService)

local config = require(ReplicatedStorage.config)
local dataTemplate = config.dataTemplate

local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {},
})

local ProfileStore = ProfileService.GetProfileStore("PlayerData", dataTemplate)

local gameData = {}

local playersData = {}

--TODO should we use Knit's Silo package to create state management for player data?

function DataService:GetDataOfPlayer(player)
	local profile = playersData[player]
	if profile ~= nil then
		return profile.Data
	end
	return nil
end

function DataService:GetServerPlayerData(player)
	return playersData
end

--TODO think of a good way to handle setting data without replacing entire dataTable
function DataService:SetDataOfPlayer(player) end

function DataService:AddNewPlayerData(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			playersData[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			playersData[player] = profile

			return LogService:Log(`Player {player.Name} data loaded successfully`, "ServerLog", "DataService")
		else
			-- Player left before the profile loaded:
			profile:Release()

			return LogService:Log(`Player {player.Name} left before data loaded`, "ServerLog", "DataService")
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick()

		--TODO link kick to moderator service

		return LogService:Log(
			`Kicked Player {player.Name} because their profile couldn't be loaded`,
			"ServerLog",
			"DataService"
		)
	end
end

--this does not kick the player, should it?
function DataService:RemovePlayer(player)
	local profile = playersData[player]
	if profile ~= nil then
		profile:Release()
	end
end

function DataService:KnitStart()
	LogService = Knit.GetService("LogService")
end

function DataService:KnitInit()
	game:BindToClose(function()
		local all = {}
		for _, player in Players:GetPlayers() do
			local save = Concur.spawn(function()
				self:RemovePlayer(player)
			end)
			table.insert(all, save)
		end
		local allConcur = Concur.all(all)
		allConcur:Await()
	end)
end

return DataService

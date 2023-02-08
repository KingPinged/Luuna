local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ProfileService = require(ReplicatedStorage.Packages.ProfileService)

local config = require(ReplicatedStorage.config)
local dataTemplate = require(ReplicatedStorage.dataTemplate)

local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {},
})

local ProfileStore = ProfileService.GetProfileStore("PlayerData", dataTemplate)

local playersData = {}

--TODO should we use Knit's Silo package to create state management for player data?

function DataService:GetDataOfPlayer(player) end

function DataService:GetServerData(player) end

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
			print("Profile successfully loaded")
		else
			-- Player left before the profile loaded:
			profile:Release()
			print("Player left before loaded")
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick()
	end
end

return DataService

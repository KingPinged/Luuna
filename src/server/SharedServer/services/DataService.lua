local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {},
})

--TODO use Knit's Silo package to create state management for player data

function DataService:GetDataOfPlayer(player) end

function DataService:GetServerData(player) end

function DataService:SetDataOfPlayer(player) end

function DataService:KnitStart()
	--TODO add database config
end

function DataService:KnitInit() end

return DataService

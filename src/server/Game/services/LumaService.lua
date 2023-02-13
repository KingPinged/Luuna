local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LumaService = Knit.CreateService({
	Name = "LumaService",
	Client = {},
})

function LumaService:GetLumaData() end

function LumaService:KnitStart() end

function LumaService:KnitInit() end

return LumaService

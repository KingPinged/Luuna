--[[
Functionality:
    -
TODO:

]]
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DayCycleController = Knit.CreateController({ Name = "DayCycleController" })

function DayCycleController:KnitStart() end

function DayCycleController:KnitInit() end

return DayCycleController

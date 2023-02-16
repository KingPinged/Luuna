local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LumaData = require(script.Parent.Parent.modules["LumaData"])

--TODO: add Sleigtnicks Table Util library

local ReplicatedStorage = require("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local Luma = {}
Luma.__index = Luma

--! This only checks if UID is same. If there are data changes to luma, it will still pass TRUE
Luma.__eq = function(a, b)
	if a.uid == b.uid then
		return true
	end
	return false
end

--TODO: instead of encoding ALL, only encode the data that is needed such as dynamic data because static data will be reconciled and stay the same after each instance of the class is created
Luma.__tostring = function(current)
	local tableToEncode = {
		name = current.name,
		data = {
			owner = current.owner,
			growthStats = current.growthStats,
			level = current.level,
			xp = current.xp,
			ability = current.ability,
			talent = current.talent,
			uid = current.uid,
		},
	}

	return HttpService:JSONEncode(tableToEncode)
end

-- @param name The name of the Luma to search and create for
-- @param options A dictionary of options to pass to the Luma
function Luma.new(name: string, options)
	local self = setmetatable({}, Luma)

	local data = LumaData[name]

	self.validated = false

	if data then
		self.validated = true

		--TODO: if options is just to populate the data, then we can just do self.TableUtil.Assign(self, options) and it will populate the data
		if options.owner then
			self.owner = options.owner
		end

		if options.growthStats then
			self.growthStats = options.growthStats
		end

		if options.level then
			self.level = options.level
		end

		if options.xp then
			self.xp = options.xp
		end

		if options.ability then
			self.ability = options.ability
		end

		if options.talent then
			self.talent = options.talent
		end

		if options.uid then
			self.uid = options.uid
		end

		self.TableUtil.Assign(self, data)
	else
		error(`Luma Data not found for id: {self.uid}`)
	end

	return self
end

function Luma:Validate()
	-- if its false, it means the data is not valid and the luma is fake or corrupted
	return self.validated
end

function Luma:Destroy() end

return Luma

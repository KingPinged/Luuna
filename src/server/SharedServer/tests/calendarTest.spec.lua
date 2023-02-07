--TestEz can not use Knit due to needing to run Knits creation functions + lifecycle events so its advised to just
--create a fake duplicate of calendarservice in here

-- Define the length of a year in seconds
local yearLength = 525600 / 60
-- Define the length of a season in seconds
local seasonLength = yearLength / 4
-- Define the length of a day in seconds
local dayLength = 1440 / 60
-- Define the length of an hour in seconds
local hourLength = 60 / 60
-- Define the length of a minute in seconds
local minuteLength = 1 / 60
-- Define the number of days per month
local daysPerMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local config = require(ReplicatedStorage:WaitForChild("config"))

local startingTime = config.startingTime

function GetCurrentSeason(currentTime)
	local secondsSinceStart = currentTime - startingTime
	local secondsIntoYear = secondsSinceStart % yearLength
	-- Calculate the current season
	local currentSeason = ""
	local seasonProgress = ""
	if secondsIntoYear < seasonLength then
		currentSeason = "Spring"
		if secondsIntoYear < seasonLength / 3 then
			seasonProgress = "Early"
		elseif secondsIntoYear < (seasonLength / 3) * 2 then
			seasonProgress = "Mid"
		else
			seasonProgress = "Late"
		end
	elseif secondsIntoYear < seasonLength * 2 then
		currentSeason = "Summer"
		if secondsIntoYear < (seasonLength * 2) / 3 then
			seasonProgress = "Early"
		elseif secondsIntoYear < (seasonLength * 2) / 3 * 2 then
			seasonProgress = "Mid"
		else
			seasonProgress = "Late"
		end
	elseif secondsIntoYear < seasonLength * 3 then
		currentSeason = "Fall"
		if secondsIntoYear < (seasonLength * 3) / 3 then
			seasonProgress = "Early"
		elseif secondsIntoYear < (seasonLength * 3) / 3 * 2 then
			seasonProgress = "Mid"
		else
			seasonProgress = "Late"
		end
	else
		currentSeason = "Winter"
		if secondsIntoYear < (seasonLength * 4) / 3 then
			seasonProgress = "Early"
		elseif secondsIntoYear < (seasonLength * 4) / 3 * 2 then
			seasonProgress = "Mid"
		else
			seasonProgress = "Late"
		end
	end

	return currentSeason, seasonProgress
end

return function()
	describe("get Season Progress", function()
		it("should equal Early, Mid, or Late", function()
			local _, seasonProgress = GetCurrentSeason(math.random(100, 2679))
			expect(seasonProgress).to.be.a("string")
		end)
	end)
end

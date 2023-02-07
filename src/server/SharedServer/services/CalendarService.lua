local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local config = require(ReplicatedStorage:WaitForChild("config"))

local startingTime = config.startingTime

local timer = require(ReplicatedStorage.Packages.Timer)

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

local CalendarService = Knit.CreateService({
	Name = "CalendarService",
	Client = {},
})

function CalendarService:GetCurrentYear(currentTime)
	-- Calculate the number of seconds since the starting time
	local secondsSinceStart = currentTime - startingTime
	-- Calculate the current year
	return math.floor(secondsSinceStart / yearLength) + 1
end

function CalendarService:GetCurrentSeason(currentTime)
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

--TODO get current Day and get Current Month have same code, combo could be used
function CalendarService:GetCurrentDay(currentTime)
	local secondsSinceStart = currentTime - startingTime
	local secondsIntoYear = secondsSinceStart % yearLength
	-- Calculate the current day of the year
	local currentDay = math.floor(secondsIntoYear / dayLength) + 1

	local currentMonth = 1
	while currentDay > daysPerMonth[currentMonth] do
		currentDay = currentDay - daysPerMonth[currentMonth]
		currentMonth = currentMonth + 1
	end

	return currentDay
end

function CalendarService:GetCurrentMonth(currentTime)
	local secondsSinceStart = currentTime - startingTime
	local secondsIntoYear = secondsSinceStart % yearLength
	-- Calculate the current day of the year
	local currentDay = math.floor(secondsIntoYear / dayLength) + 1

	local currentMonth = 1
	while currentDay > daysPerMonth[currentMonth] do
		currentDay = currentDay - daysPerMonth[currentMonth]
		currentMonth = currentMonth + 1
	end

	return currentMonth
end

function CalendarService:GetCurrentHour(currentTime)
	local secondsSinceStart = currentTime - startingTime
	local secondsIntoYear = secondsSinceStart % yearLength
	return math.floor(secondsIntoYear % dayLength / hourLength)
end

function CalendarService:GetCurrentMinute(currentTime)
	local secondsSinceStart = currentTime - startingTime
	local secondsIntoYear = secondsSinceStart % yearLength
	return math.floor(secondsIntoYear % hourLength / minuteLength)
end

--TODO stack the methods that use same methods to use each other
function CalendarService:KnitStart()
	print("CalendarService started")
	timer.Simple(1, function()
		local currentTime = os.time()

		local currentYear = self:GetCurrentYear(currentTime)

		--SeasonProgress is Early, Mid, or Late as TEXT
		local currentSeason, seasonProgress = self:GetCurrentSeason(currentTime)

		local currentDay = self:GetCurrentDay(currentTime)

		local currentHour = self:GetCurrentHour(currentTime)

		local currentMinute = self:GetCurrentMinute(currentTime)

		local currentDayText = currentDay
		if currentDay == 1 or currentDay == 21 or currentDay == 31 then
			currentDayText = currentDay .. "st"
		elseif currentDay == 2 or currentDay == 22 then
			currentDayText = currentDay .. "nd"
		elseif currentDay == 3 or currentDay == 23 then
			currentDayText = currentDay .. "rd"
		else
			currentDayText = currentDay .. "th"
		end

		local timeOfDay = ""
		if currentHour >= 0 and currentHour < 12 then
			timeOfDay = "AM"
		else
			timeOfDay = "PM"
			currentHour = currentHour % 12
			if currentHour == 0 then
				currentHour = 12
			end
		end

		if currentHour == 0 then
			currentHour = 12
		end

		-- print(
		-- 	`{seasonProgress} {currentSeason} {currentDayText} |  {string.format("%02d", currentHour)}:{string.format("%02d", currentMinute)} {timeOfDay} | Year {currentYear}`
		-- )
	end)
end

function CalendarService:KnitInit() end

return CalendarService

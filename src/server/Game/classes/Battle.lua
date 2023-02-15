

local Battle = {}
Battle.__index = Battle

-- @param team1 an dictionary @param team | a dict with instances of Luma class
-- @param team2 an dictionary @param team | a dict with instances of Luma class
-- @param options an optional dictionary
function Battle.new(team1, team2, options)
	local self = setmetatable({}, Battle)


	self.team1 = team1.team
	self.team2 = team2.team

	self.players = {}
	if team1.player then
		table.insert(players, team1.player)
	end

	if team2.player then
		table.insert(players, team2.player)
	end

	self.options = options

	self.team1ActiveLuma = self.team1[1]
	self.team2ActiveLuma = self.team2[1]

	return self
end

-- called before the turn start
function beforeTurnStart() end

--called after the turn ends
function afterTurnEnd() end

-- calculates which luma goes first
-- luma1 is team1 , luma2 is team2
--! I dont like this param format
-- returns 1 or 2, 1 is team 1, 2 is team 2
function battle.calculateTurn(luma1, luma2, move1, move2) 

	--move priority is a level. Calculated before speed caluclations
	if move1.priority  > move2.priority then
		return 1
	elseif move1.priority < move2.priority then
		return 2
	end

	local luma1Speed = luma1.data.growthStats.speed + luma1.stats.speed
	local luma2Speed = luma2.data.growthStats.speed + luma2.stats.speed

	if luma1Speed > luma2Speed then
		return 1
	elseif luma1Speed < luma2Speed then
		return 2
	else
		--they are equal. Randomized
		return math.random(1, 2)
	end
end
end

function Battle:aiMove() end

function Battle:Destroy() end

return Battle

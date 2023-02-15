local Battle = {}
Battle.__index = Battle

-- @param team1 an dictionary
-- @param team2 an dictionary
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
function battle.calculateTurn(luma1, luma2, move1, move2) 
	local luma1Speed = luma1.speed
	local luma2Speed = luma2.speed



	if luma1Speed > luma2Speed then
		return 1
	elseif luma1Speed < luma2Speed then
		return 2
	else
		return math.random(1, 2)
	end
end
end

function Battle:aiMove() end

function Battle:Destroy() end

return Battle

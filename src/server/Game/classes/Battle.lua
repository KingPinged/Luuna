local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleActions = require(script.Parent.BattleActions)

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local ClassUtil = require(ReplicatedStorage.tools.classUtil)

local Battle = {}
Battle.__index = Battle

--- @param team1 an dictionary @param team | a dict with instances of Luma class
--- @param team2 an dictionary @param team | a dict with instances of Luma class
--- @param options an optional dictionary
function Battle.new(team1, team2, options)
	local self = setmetatable({}, Battle)

	self.team1 = team1.team
	self.team2 = team2.team

	self.battleActions = BattleActions.new(self)

	self.players = {}
	if team1.player then
		table.insert(self.players, team1.player)
	end

	if team2.player then
		table.insert(self.players, team2.player)
	end

	self.options = options

	TableUtil.Map(self.team1, function(luma)
		TableUtil.Extend(luma, { statuses = {} })
	end)

	TableUtil.Map(self.team2, function(luma)
		TableUtil.Extend(luma, { statuses = {} })
	end)

	self.team1ActiveLuma = self.team1[1]
	self.team2ActiveLuma = self.team2[1]

	return self
end

---@param eventid the id of the event
function Battle:runEvent(eventId, target, source)
	--Get all handlers for the event and call them
	local handlers = self:findEventHandlers(eventId, target, source)

	for _, handler in pairs(handlers) do
		handler.callback(self, target, source)
	end
end
---@param eventId the id of the event
---@param target the target of the event
---@param source the source of the event

function Battle:findEventHandlers(eventId, target, source)
	local handlers = {}

	--of luma class
	if ClassUtil:instanceOf(target, "Luma") then
		local ability = target.getAbility()

		local callback = ability[eventId]
		if callback ~= nil then
			table.insert(handlers, { callback = callback, type = "ability" })
		end
	end

	return handlers
end
--TODO: check if the moves are valid

--- @param move1 the move of team1 | a dict
--- @param move2 the move of team2 | a dict
function Battle:executeMoves(luma1, luma2, move1, move2)
	if move1.type == "switch" then
		--check if the switch is possible
		if move1.switchTo then
			if self.team1[move1.switchTo] and self.team1[move1.switchTo].health > 0 then
				self.team1ActiveLuma = self.team1[move1.switchTo]
			else
				--TODO: error immediately. Either bug or hacker
			end
		else
			-- TODO: error immediately. Either bug or hacker
		end
	elseif move1.type == "move" then
	elseif move1.type == "run" then
	elseif move1.type == "item" then
	else
		--TODO: invalid move type. Either bug or hacker
	end

	if move2.type == "switch" then
	elseif move2.type == "move" then
	elseif move1.type == "run" then
	elseif move1.type == "item" then
	else
		--TODO: invalid move type. Either bug or hacker
	end

	local turn = self.calculateTurn(luma1, luma2, move1, move2)

	-- I do not like this format of determining who goes first. Change in the future dumbass
	if turn == 1 then
		self:useMove(Luma1, Luma2, move1)
		self:useMove(Luma2, Luma1, move2)
	--its turn of second team
	else
		self:useMove(Luma2, Luma1, move2)
		self:useMove(Luma1, Luma2, move1)
	end
end

--! TODO: I HATE THIS SO MUCH. YOU FUCKING DUMBASS CHANGE THIS SHIT WHY IS IT SO REPETITIVE
function Battle:useMove(Luma1, Luma2, move)
	if move.attackType == "physical" then
		--calculate defense and damage
		local damage = (
			(
				((2 * Luma1.level / 5) + 2)
				* move.power
				* (luma1.data.growthStats.attack + luma1.baseStats.attack)
				* TableUtil.Reduce(luma1.statuses, function(accum, status)
					if status.attackModifier then
						return accum + status.attackModifier
					end
					return accum
				end)
			)
			/ (
				(50 * (luma2.data.growthStats.defense + luma2.baseStats.defense))
				* TableUtil.Reduce(luma2.statuses, function(accum, status)
					if status.attackModifier then
						return accum + status.attackModifier
					end
					return accum
				end)
			)
		)

		luma2.hp -= damage
	elseif move.attackType == "ranged" then
		--calculate defense and damage
		local damage = (
			(
				((2 * Luma1.level / 5) + 2)
				* move.power
				* (luma1.data.growthStats.rangedAttack + luma1.baseStats.rangedAttack)
				* TableUtil.Reduce(luma1.statuses, function(accum, status)
					if status.rangedAttackModifier then
						return accum + status.rangedAttackModifier
					end
					return accum
				end)
			)
			/ (
				(50 * (luma2.data.growthStats.rangedDefense + luma2.baseStats.rangedDefense))
				* TableUtil.Reduce(luma2.statuses, function(accum, status)
					if status.rangedAttackModifier then
						return accum + status.rangedAttackModifier
					end
					return accum
				end)
			)
		)

		luma2.hp -= damage
	end

	--TODO: check if there's a status effect

	return luma2.hp
end

-- called before the turn start
function beforeTurnStart() end

--called after the turn ends
function afterTurnEnd() end

-- calculates which luma goes first
-- luma1 is team1 , luma2 is team2
--! I don't like this param format
-- returns 1 or 2, 1 is team 1, 2 is team 2
function Battle.calculateTurn(luma1, luma2, move1, move2)
	--move priority is a level. Calculated before speed calculations
	if move1.priority > move2.priority then
		return 1
	elseif move1.priority < move2.priority then
		return 2
	end

	local luma1Speed = luma1.data.growthStats.speed
		+ luma1.baseStats.speed
			* TableUtil.Reduce(luma1.statuses, function(accum, status)
				if status.speedModifier then
					return accum + status.speedModifier
				end
				return accum
			end)
	local luma2Speed = luma2.data.growthStats.speed
		+ luma2.baseStats.speed
			* TableUtil.Reduce(luma2.statuses, function(accum, status)
				if status.speedModifier then
					return accum + status.speedModifier
				end
				return accum
			end)

	if luma1Speed > luma2Speed then
		return 1
	elseif luma1Speed < luma2Speed then
		return 2
	else
		--they are equal. Randomized
		return math.random(1, 2)
	end
end

function Battle:aiMove() end

function Battle:Destroy() end

return Battle

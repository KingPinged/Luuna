local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleActions = require(script.BattleActions)

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local ClassUtil = require(ReplicatedStorage.tools.classUtil)

local Battle = {}
Battle.__index = Battle

--- @param team1 an dictionary @param team | a dict with instances of Luma class
--- @param team2 an dictionary @param team | a dict with instances of Luma class
--- @param options an optional dictionary
function Battle.new(player)
	local self = setmetatable({}, Battle)

	self.runAttempts = 0
	self.turn = 0
	--	p1 = nil,
	--	p2 = nil,
	self.lastUpdate = 0
	self.weather = ""
	self.terrain = ""
	self.ended = false
	self.started = false
	self.active = false
	self.eventDepth = 0
	self.lastMove = ""
	self.midTurn = false
	self.currentRequest = ""
	self.currentRequestDetails = ""
	self.rqid = 0
	self.lastMoveLine = 0
	self.reportPercentages = false
	self.supportCancel = false
	self.log = {}
	self.sides = { null, null }
	--	self.roomid = roomid
	--	self.id = roomid
	--	self.rated = rated
	self.weatherData = { id = "" }
	self.terrainData = { id = "" }
	self.pseudoWeather = {}

	self.format = toId(format)
	self.formatData = { id = self.format }

	self.effect = { id = "" }
	self.effectData = { id = "" }
	self.event = { id = "" }

	--	print('Game Type:', self.gameType)
	self.gameType = self.gameType or "singles"

	self.queue = {}
	self.faintQueue = {}
	--	self.messageLog = {}

	self.listeningPlayers = {}
	self.spectators = {}
	self.queriedData = {}
	self.transferDataToP1 = {}
	self.transferDataToP2 = {}
	self.transferDataToSpec = {}

	self.giveExp = {}

	self.arq_data = {}
	self.arq_count = 0

	local data = {}

	if self.expShare then
		if creatingPlayer then
			local bd = _f.PlayerDataService[creatingPlayer]:getBagDataById("expshare", 5)
			if not bd or not bd.quantity or bd.quantity <= 0 then
				self.expShare = nil
			end
		else
			self.expShare = nil
		end
	end

	-- get battle scene
	local scene
	if _f.Context == "battle" then
		local folder = storage.Models.BattleScenes[self.gameType == "doubles" and "DoubleFields" or "SingleFields"]
		pcall(function()
			scene = folder[self.location]
		end)
		if scene then
			local defaultScene = folder.Default
			for _, partName in pairs({ "_User", "_Foe", "pos11", "pos12", "pos21", "pos22" }) do -- todo: triples
				if not scene:FindFirstChild(partName) then
					local p = defaultScene:FindFirstChild(partName)
					if p then
						p:Clone().Parent = scene
					end
				end
			end
		else
			scene = folder.Default
		end
	else
		local chunkId, regionId, roomId = self.chunkId, self.regionId, self.roomid
		local chunkData = chunkId and _f.Database.ChunkData[chunkId]
		local regionData = chunkData and regionId and chunkData.regions and chunkData.regions[regionId]
		local roomData = chunkData and roomId and chunkData.buildings and chunkData.buildings[roomId]

		if self.battleSceneType then -- try the scene specific to this battle
			pcall(function()
				scene = storage.Models.BattleScenes[self.battleSceneType]
			end)
			if not scene then -- try the scene specific to this battle @ Day / Night
				pcall(function()
					scene = storage.Models.BattleScenes[self.battleSceneType .. (self.isDay and "Day" or "Night")]
				end)
			end
		end
		if not scene then
			pcall(function() -- try the scene of the current room's roomdata
				scene = storage.Models.BattleScenes[roomData.BattleSceneType]
			end)
		end
		if not scene and self.gameType == "doubles" then -- try the chunk region scene + Double (if applic.)
			pcall(function()
				scene = storage.Models.BattleScenes[regionData.BattleScene .. "Double"]
			end)
		end
		if not scene then -- try the scene of the chunk region @ Day / Night
			pcall(function()
				scene = storage.Models.BattleScenes[regionData.BattleScene .. (self.isDay and "Day" or "Night")]
			end)
		end
		if not scene then -- try the scene of the chunk region
			pcall(function()
				scene = storage.Models.BattleScenes[regionData.BattleScene]
			end)
		end
		if not scene then -- default scene
			local defaultName = "Route"
			if self.gameType == "doubles" then
				defaultName = "Double"
			end
			scene = storage.Models.BattleScenes[defaultName .. (self.isDay and "Day" or "Night")]
		end
	end
	self.scene = scene
	if creatingPlayer then
		data.scene = scene:Clone()
		data.scene.Parent = creatingPlayer:WaitForChild("PlayerGui")
	else
		data.scene = true
	end
	--

	if self.battleType == BATTLE_TYPE_WILD and self.eid then
		-- eid = encounter id
		-- rfl = repel-forced level
		local PlayerData = _f.PlayerDataService[creatingPlayer]

		self.yieldExp = true
		self.RoPowerExpMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(1) / 2
		self.RoPowerEVMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(4)
		self.RoPowerCatchMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(6)
		--		self.startWeather = self.startWeather -- OVH  todo

		local encounterData = encounterLists[self.eid]
		-- encounters with special verification
		if encounterData.Verify and not encounterData.Verify(PlayerData) then
			return false
		end -- should it be nil-enabled?
		-- encounters associated with events
		if encounterData.PDEvent and PlayerData:completeEventServer(encounterData.PDEvent) == false then
			return false
		end
		-- encounters with weather
		if encounterData.Weather then
			self.startWeather = encounterData.Weather
		end
		-- encounters with special getters
		local pokemon

		if encounterData.GetPokemon then
			local s, r = pcall(function()
				return encounterData.GetPokemon(PlayerData)
			end)
			if not s or not r then
				return false
			end
			pokemon = r
		else
			local encounterList = encounterData.list
			local rfl = self.rfl -- repel-forced level
			-- attempt a roaming encounter
			local roamChance = 4 -- out of 4096
			if PlayerData:ROPowers_getPowerLevel(7) >= 1 then
				roamChance = roamChance * 4
			end
			if PlayerData:ownsGamePass("RoamingCharm", true) then
				roamChance = roamChance * 2
			end
			local shinyChance = 4096
			if
				not encounterData.Locked
				and not encounterData.Verify
				and not encounterData.PDEvent
				and not encounterData.rod
				and PlayerData:random2(4096) <= roamChance
			then
				local list = {}
				for eventName, encounters in pairs(roamingEncounter) do
					if PlayerData.completedEvents[eventName] then
						for _, enc in pairs(encounters) do
							list[#list + 1] = { enc[1], 40, 40, enc[2] }
						end
					end
				end
				if #list > 0 then
					encounterList = list
					rfl = nil
					data.musicId = 380888758
					data.musicVolume = 0.4
				end
			end
			--
			if rfl then
				local modifiedEncounter = {}
				for _, entry in pairs(encounterList) do
					if
						entry[2] <= rfl
						and entry[3] >= rfl
						and (
							not entry[5]
							or (entry[5] == "day" and self.isDay)
							or (entry[5] == "night" and not self.isDay)
						)
					then
						modifiedEncounter[#modifiedEncounter + 1] = entry
					end
				end
				if #modifiedEncounter > 0 then -- defaults to normal random encounter in case something went wrong
					encounterList = modifiedEncounter
				end
			end
			local foe = weightedRandom(encounterList, function(p)
				if p[5] == "day" and not self.isDay then
					return 0
				end
				if p[5] == "night" and self.isDay then
					return 0
				end
				return p[4]
			end)

			if encounterData.rod then
				shinyChance = math.floor(
					4096 * math.max(0.025, math.cos(math.min(PlayerData.fishingStreak, 100) / 100 * math.pi / 2))
				)
				PlayerData.fishingStreak = PlayerData.fishingStreak + 1
			end
			if foe[6] == false then -- forces NOT shiny
				shinyChance = nil
			end
			local foeData = {
				name = foe[1],
				level = (rfl and foe[2] <= rfl and foe[3] >= rfl) and rfl or math.random(foe[2], foe[3]),
				shinyChance = shinyChance,
				-- [6] = forced shiny
				forme = foe[7],
			}
			pokemon = _f.ServerPokemon:new(foeData, PlayerData)
			if pokemon.shiny then
				PlayerData:resetFishStreak()
			end
			if
				PlayerData:ownsGamePass("AbilityCharm", true)
				and pokemon.data.hiddenAbility
				and PlayerData:random2(512) == 69
			then
				pokemon.hiddenAbility = true
			end
			local firstNonEgg = PlayerData:getFirstNonEgg()
			if firstNonEgg:getAbilityName() == "Synchronize" and math.random(2) == 1 then
				pokemon.nature = firstNonEgg.nature
			end
		end

		self.alreadyOwnsFoeSpecies = PlayerData:hasOwnedPokemon(pokemon.num)
		PlayerData:onSeePokemon(pokemon.num)

		self.wildFoePokemon = pokemon

		self:join(nil, 2, "#Wild", { pokemon:getBattleData() }) --player, slot, name, team, megaadornment
	elseif self.battleType == BATTLE_TYPE_NPC then
		local PlayerData = _f.PlayerDataService[creatingPlayer]

		self.yieldExp = true
		self.isTrainer = true

		self.RoPowerMoneyMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(3)
		self.RoPowerExpMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(1) / 2
		self.RoPowerEVMultiplier = 1 + PlayerData:ROPowers_getPowerLevel(4)
		--		self.startWeather = self.startWeather -- OVH  todo

		-- OVH  todo: verify they haven't already fought this trainer, or that the trainer is rematchable
		local trainerId = tonumber(self.trainerId)
		local trainer = _f.Database:getBattle(trainerId)
		trainer.id = trainerId
		self.npcTrainerData = trainer
		if trainer.Weather then
			self.startWeather = trainer.Weather
		end
		--		print 'PARTY'; require(game.ServerStorage.Utilities).print_r(trainer.Party)
		self:join("npc", 2, trainer.Name, trainer.Party)
	elseif self.battleType == BATTLE_TYPE_PVP then
		self.pvp = true
	else
		error("unknown battle structure")
	end

	-- Get a unique ID
	local id
	repeat
		id = uid()
	until not Battles[id]
	self.id = id
	self.roomid = id

	Battles[id] = self

	self.createdAt = tick()

	data.battleId = id
	self.creationData = data

	self.log = {}

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

---Adds the log to the battle log which logs EVERY single event which is necessary
function Battle:addLog(...)
	local args = { ... }
	local hasFn = false
	for _, f in pairs(args) do
		if type(f) == "function" then
			hasFn = true
			break
		end
	end
	if not hasFn then
		table.insert(self.log, "|" .. concat(args, "|"))
	else
		local line = ""
		for _, arg in pairs(args) do
			line = line .. "|"
			if type(arg) == "function" then
				line = line .. arg(true)
			else
				line = line .. arg
			end
		end
		table.insert(self.log, line)
	end
end

---@param eventid the id of the event
function Battle:runEvent(eventId, target, source)
	--Get all handlers for the event and call them
	local handlers = self:findEventHandlers(eventId, target, source)

	for _, handler in pairs(handlers) do
		--TODO: check if self is handled as a unique case and we can call self methods inside of another file instead of doing
		-- self = handler.callback(self, target, source)
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

function Battle:choose(player, sideid, choice, rqid)
	local side
	if sideid == "p1" or sideid == "p2" then
		side = self[sideid]
	end
	if not side then
		return
	end

	-- this condition can occur if the client sends a decision at the wrong time.
	if side.currentRequest == "" then
		return
	end

	-- Make sure the decision is for the right request.
	if rqid and tonumber(rqid) ~= self.rqid then
		return
	end

	if type(choice) == "string" then
		choice = split(choice, ",")
	end

	if side.decision and side.decision.finalDecision and not side.decision.isIncomplete then
		self:debug("Can't override decision: the last pokemon could have been trapped or disabled")
		return
	end

	side.decision = self:parseChoice(player, choice, side)

	if
		self.p1.decision
		and self.p2.decision
		and (type(self.p1.decision) ~= "table" or not self.p1.decision.isIncomplete)
		and (type(self.p2.decision) ~= "table" or not self.p2.decision.isIncomplete)
	then
		self:commitDecisions()
	end
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

function Battle:Destroy() end

function Battle:debug(...)
	warn("[Battle] " .. table.concat({ ... }, " "))
	--TODO: go to log service
end

return Battle

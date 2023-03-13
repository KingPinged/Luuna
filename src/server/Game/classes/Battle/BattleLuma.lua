---This file  is for the battle luma instance

local BattleLuma = {}
BattleLuma.__index = BattleLuma

function BattleLuma.new(set, side)
	local self = setmetatable({}, BattleLuma)

    trapped = false,
	hp = 0,
	maxhp = 100,
--	illusion = nil,
	fainted = false,
	faintQueued = false,
	lastItem = '',
	ateBerry = false,
	status = '',
	position = 0,
	
	lastMove = '',
	moveThisTurn = '',
--	activeTurns = 0, -- was gonna make this a thing, haven't yet
	
	lastDamage = 0,
--	lastAttackedBy = nil,
	usedItemThisTurn = false,
	newlySwitched = false,
	beingCalledBack = false,
	isActive = false,
	isStarted = false,
	transformed = false,
	duringMove = false,
	speed = 0,


	self.side = side
	self.battle = side.battle
	
	self.getHealth = function(side) return BattleLuma.getHealth(self, side) end
	self.getDetails = function(side) return BattleLuma.getDetails(self, side) end
	
	self.set = set
	
	self.baseTemplate = self.battle:getTemplate(set.id)

	if set.forme then
		local id = self.baseTemplate.species .. '-' .. set.forme
		local formeTemplate = self.battle:getTemplate(id)
		if formeTemplate.exists then
			self.baseTemplate = formeTemplate
		end
		if _f.Database.GifData._FRONT[id] then --require(game:GetService('ServerStorage').Data.GifData)._FRONT[id] then
			self.spriteForme = set.forme
		end
	end
	self.stamps = set.stamps
	self.species = self.baseTemplate.species
	if set.name == set.species or not set.name or not set.species then
		set.name = self.species -- lulwut
	end
	self.name = set.nickname or set.name
	self.speciesid = toId(self.species)
	self.template = self.baseTemplate
	self.moves = {}
	self.baseMoves = self.moves
	self.movepp = {}
	self.moveset = {}
	self.baseMoveset = {}
	
	self.level = self.battle:clampIntRange(self.battle.forcedLevel or set.level or 1, 1, 100)
	
	self.gender = set.gender
	
	self.happiness = set.happiness or self.baseTemplate.baseHappiness
	
	self.fullname = self.side.id .. ': ' .. self.name
	self.details = self.species .. ', L' .. self.level .. (self.gender == '' and '' or ', ') .. self.gender .. (set.shiny and ', shiny' or '')
	if set.shiny then self.shiny = true end
	
	self.id = self.fullname -- shouldn't really be used anywhere
	
	self.statusData = {}
	self.volatiles = {}
--	self.negateImmunity = {}
	
	self.height = self.template.height
	self.heightm = self.template.heightm
	self.weight = self.template.weight
	self.weightkg = self.template.weightkg
	
	if type(set.ability) == 'number' then
--		if not self.baseTemplate.abilities then
--			print(self.baseTemplate.species)
--			require(game.ServerStorage.Utilities).print_r(self.baseTemplate)
--		end
		if set.ability == 3 and self.baseTemplate.hiddenAbility then
			set.ability = self.baseTemplate.hiddenAbility
		elseif set.ability == 2 and #self.baseTemplate.abilities > 1 then
			set.ability = self.baseTemplate.abilities[2]
		else
			set.ability = self.baseTemplate.abilities[1]
		end
	end
	self.baseAbility = toId(set.ability)
	self.ability = self.baseAbility
	if set.item then self.item = toId(set.item) end
	self.abilityData = {id = self.ability}
	self.itemData = {id = self.item}
	self.speciesData = {id = self.speciesid}
	
	self.types = {}
	if not self.template.types then
		print('potentially corrupt template:', set.id)
	end
	for i, t in pairs(self.template.types) do
		self.types[i] = self.battle.data.TypeFromInt[t]
	end
	self.typesData = {}
	for _, t in pairs(self.types) do
		table.insert(self.typesData, { type = t, suppressed = false, isAdded = false })
	end
	
	if not set.moves then
		local moves = {}
		local learnedMoves = _f.Database.LearnedMoves[self.baseTemplate.num]
		if self.species == 'Meowstic' and self.gender == 'F' then
			learnedMoves = _f.Database.FemaleMeowsticLearnedMoves
		end
		for _, d in pairs(learnedMoves.levelUp) do
			if self.level < d[1] then break end
			for i = 2, #d do
				table.insert(moves, d[i])
			end
		end
		local known = {}
		for i = #moves, 1, -1 do
			local num = moves[i]
			if known[num] then
				table.remove(moves, i)
			else
				known[num] = true
			end
		end
		while #moves > 4 do
			table.remove(moves, 1)
		end
		for i, num in pairs(moves) do
			moves[i] = {id = _f.Database.MoveByNumber[num].id}
		end
		set.moves = moves
	end
	for i, m in pairs(set.moves) do
		local move = self.battle:getMove(m.id)
		if move.id then
			table.insert(self.baseMoveset, {
				move = move.name,
				id = move.id,
				pp = m.pp or move.pp,--(move.noPPBoosts and move.pp or move.pp * 8 / 5),
				maxpp = m.maxpp or move.pp,--(move.noPPBoosts and move.pp or move.pp * 8 / 5),
				target = (move.nonGhostTarget and not self:hasType('Ghost')) and move.nonGhostTarget or move.target,
				disabled = false,
				used = false
			})
			table.insert(self.moves, move.id)
		end
	end
	self.disabledMoves = {}
	
	self.canMegaEvo = self.battle:canMegaEvo(self)
	
	self.evs = {}
	self.ivs = {}
	if not set.evs then
		set.evs = {0, 0, 0, 0, 0, 0}
	end
	for i, v in pairs({'hp','atk','def','spa','spd','spe'}) do
		self.evs[v] = self.battle:clampIntRange(set.evs[i], 0, 252)
		self.ivs[v] = self.battle:clampIntRange(set.ivs[i], 0, 31)
	end
	
	if not self.hpType then
		local hpTypes = {'Fighting', 'Flying', 'Poison', 'Ground', 'Rock', 'Bug', 'Ghost', 'Steel', 'Fire', 'Water', 'Grass', 'Electric', 'Psychic', 'Ice', 'Dragon', 'Dark'}
		local hpTypeX = 0
		local i = 1
		for s in pairs({'hp','atk','def','spa','spd','spe'}) do
			hpTypeX = hpTypeX + i * (set.ivs[s] % 2)
			i = i * 2
		end
		self.hpType = hpTypes[math.floor(hpTypeX * 15 / 63)]
		-- In Gen 6, Hidden Power is always 60 base power
	end
	
	self.boosts = {
		atk = 0, def = 0, spa = 0, spd = 0, spe = 0,
		accuracy = 0, evasion = 0
	}
	self.stats = {atk = 0, def = 0, spa = 0, spd = 0, spe = 0}
	self.baseStats = {atk = 10, def = 10, spa = 10, spd = 10, spe = 10}
	local statIndices = {atk = 2, def = 3, spa = 4, spd = 5, spe = 6}
	local nature = self.battle:getNature(set.nature)
	for statName in pairs(self.baseStats) do
		local stat = self.template.baseStats[statIndices[statName]]
		stat = math.floor(math.floor(2 * stat + self.ivs[statName] + math.floor(self.evs[statName] / 4)) * self.level / 100 + 5)
		
		if statName == nature.plus then stat = stat * 1.1 end
		if statName == nature.minus then stat = stat * 0.9 end
		self.baseStats[statName] = math.floor(stat)
	end
	
	self.maxhp = math.floor(math.floor(2 * self.template.baseStats[1] + self.ivs['hp'] + math.floor(self.evs['hp'] / 4) + 100) * self.level / 100 + 10)
	if self.template.baseStats[1] == 1 then self.maxhp = 1 end -- Shedinja
	self.hp = math.min(self.maxhp, set.hp or self.maxhp)
	
	self.isStale = 0
	self.isStaleCon = 0
	self.isStaleHP = self.maxhp
	self.isStalePPTurns = 0
	
	self.baseIvs = deepcopy(self.ivs)
	self.baseHpType = self.hpType
	
	self.ball = set.pokeball or 1
	
	self.participatingFoes = {}
	self.isNotOT = set.isNotOT
	self.pokerus = set.pokerus
	
	self.index = set.index
	self.originalPartyIndex = set.originalPartyIndex
	
	self.aiStrategy = set.strategy
	
	if set.isEgg then self.isEgg = true end
	
	self:clearVolatile(true)
	
	
	return self
end

function BattleLuma:Destroy() end

return BattleLuma

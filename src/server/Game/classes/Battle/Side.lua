local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = ReplicatedStorage:WaitForChild("config")

local BattleLuma = require(script.Parent.BattleLuma)

local Side = {}
Side.__index = Side

function Side.new(name, battle, n, team)
	local self = setmetatable({}, Side)
	self.battle = battle
	self.n = n
	self.name = name

	self.luma = {}
	self.sideConditions = {}
	self.active = {}

	self.id = `p{n}`

	local alive = 0

	for i = 1, math.min(#team, config.maxTeamSize) do
		local luma = BattleLuma.new(nil, team[i], self)
		if not luma.index then
			luma.index = i
		end
		table.insert(self.luma, luma)
		luma.fainted = luma.hp == 0
		if luma.hp > 0 then
			alive = alive + 1
		end
	end
	self.lumaLeft = alive

	for i = 1, #self.luma do
		self.luma[i].position = i
	end

	return self
end

function Side:Start()
	local pos = 1
	for i, l in pairs(self.luma) do
		if l.hp > 0 then
			self.battle:switchIn(l, pos)
			pos = pos + 1
			if pos > #self.active then
				break
			end
		end
	end
end

function Side:getData(context)
	local data = {
		id = self.id,
		nActive = #self.active,
	}
	if context == "switch" then
		local h = {}
		data.healthy = h
		for i, pokemon in pairs(self.pokemon) do
			h[i] = not pokemon.egg and pokemon.hp > 0
		end
	end
	return data
end

function BattleSide:AIChooseMove(request)
	if request.requestType ~= "move" then
		self.battle:debug("non-move request sent to AI foe side")
		return
	end
	local choices = {}
	for n, a in pairs(request.active) do
		-- get valid moves
		local enabledMoves = {}
		for i, m in pairs(a.moves) do
			if not m.disabled and (not m.pp or m.pp > 0) then
				table.insert(enabledMoves, i)
			end
		end

		-- if npc trainer, then try to use some logic to decide move
		local move
		if self.name ~= "#Wild" then
			local s, r = pcall(function()
				local battle = self.battle
				local pokemon = self.active[n]
				-- for now, assume target is always slot 1 (THIS COULD HILARIOUSLY AFFECT DOUBLES W/ JAKE/TESS)
				local target = self.foe.active[1]
				if target == null then
					target = self.foe.active[2]
				end
				if target == null then
					target = self.foe.active[3]
				end
				if target == null then
					target = nil
				end
				-- check for a manually designed strategy
				if pokemon.aiStrategy then
					local trymovenamed = pokemon.aiStrategy(battle, self, pokemon, target)
					if trymovenamed then
						for _, m in pairs(enabledMoves) do
							if pokemon.moves[m] == trymovenamed then
								--								print('ai strategy successful')
								move = m
								break
							end
						end
					end
				end
				-- special Shedinja logic
				if not move and target.ability == "wonderguard" then
					local superEffectiveMoves = {}
					local nonDamageMoves = {}
					for _, m in pairs(enabledMoves) do
						local moveId = pokemon.moves[m]
						local moveData = battle:getMove(moveId)
						if moveData.baseDamage > 0 then
							local effectiveness = 1
							for _, t in pairs(target:getTypes()) do
								effectiveness = effectiveness * (battle.data.TypeChart[t][moveData.type] or 1)
							end
							if effectiveness > 1 then
								table.insert(superEffectiveMoves, m)
							end
						else
							table.insert(nonDamageMoves, m)
						end
					end
					if #superEffectiveMoves > 0 then
						move = superEffectiveMoves[math.random(#superEffectiveMoves)]
					else
						-- TODO: switch to something that can defeat Shedinja
						move = nonDamageMoves[math.random(#nonDamageMoves)]
					end
				end
				--
				if not move then
					local chance = { 0, 0, 0, 0 }
					for _, m in pairs(enabledMoves) do
						chance[m] = 1
					end
					local difficulty = self.difficulty or 1
					--					print('difficulty', difficulty)
					local d_alpha = math.max(0, math.min(1, difficulty / 4))
					local estDamage = { 0, 0, 0, 0 }
					for _, m in pairs(enabledMoves) do
						local moveId = pokemon.moves[m]
						local moveData = battle:getMove(moveId)
						-- don't heal if it won't help (excludes absorb etc. that still deal damage)
						if
							moveData.flags.heal
							and (not moveData.basePower or moveData.basePower < 1)
							and pokemon.hp == pokemon.maxhp
						then
							chance[m] = 0
						-- don't bother setting weather if it's already set
						elseif moveData.weather and battle:isWeather(moveData.weather) then
							chance[m] = 0
						end
						-- avoid known fail states
						if moveId == "helpinghand" and #self.active < 2 then
							chance[m] = 0
						end
						-- status logic
						if moveData.status and target.status ~= "" then
							chance[m] = target.status == "slp" and 0.25 or 0
						elseif moveData.status == "slp" then
							chance[m] = 1 + 0.01 * ((tonumber(moveData.accuracy) or 100) - 30)
						end
						if moveId == "spore" and target:hasType("Grass") then
							chance = 0
						end
						-- estimate damage dealt by this move
						local effectiveBaseDamage = moveData.baseDamage or 0
						if effectiveBaseDamage > 0 then
							-- SPECIFICS (for gym leaders, etc)
							if pokemon.ability == "technician" and effectiveBaseDamage <= 60 then
								effectiveBaseDamage = effectiveBaseDamage * 1.5
							end
							if moveId == "venoshock" and (target.status == "psn" or target.status == "tox") then
								effectiveBaseDamage = effectiveBaseDamage * 2
							end
							-- END SPECIFICS
							-- consider charging moves as being half as powerful
							if
								moveData.flags.charge
								and pokemon.item ~= "powerherb"
								and not (moveId == "solarbeam" and battle:isWeather({ "sunnyday", "desolateland" }))
							then
								effectiveBaseDamage = effectiveBaseDamage / 2
							-- same with recharging moves (unless it's the opponent's last pokemon)
							elseif moveData.flags.recharge and self.foe.pokemonLeft > 1 then
								effectiveBaseDamage = effectiveBaseDamage / 2
							end
							-- factor in move's accuracy
							if type(moveData.accuracy) == "number" then
								effectiveBaseDamage = effectiveBaseDamage * 100 / moveData.accuracy
							end
							-- factor in crit chance
							if moveData.willCrit then
								effectiveBaseDamage = effectiveBaseDamage * 1.5
							elseif moveData.critRatio and moveData.critRatio > 1 then
								effectiveBaseDamage = effectiveBaseDamage
									* (1.5 / ({ 16, 8, 2, 1 })[math.min(4, moveData.critRatio)])
							end
							-- factor in STAB
							if pokemon:hasType(moveData.type) then
								effectiveBaseDamage = effectiveBaseDamage * (moveData.stab or 1.5)
							end

							if target then
								local minDamage, maxDamage
								if moveData.damage == "level" then
									minDamage, maxDamage = pokemon.level, pokemon.level
								elseif moveData.damage then
									minDamage, maxDamage = moveData.damage, moveData.damage
								else
									local category = battle:getCategory(moveData)
									local defensiveCategory = moveData.defensiveCategory or category

									local level = pokemon.level

									local attackStat = (category == "Physical") and "atk" or "spa"
									local defenseStat = (defensiveCategory == "Physical") and "def" or "spd"
									local statTable =
										{ atk = "Atk", def = "Def", spa = "SpA", spd = "SpD", spe = "Spe" }
									local attack, defense

									local atkBoosts = moveData.useTargetOffensive and target.boosts[attackStat]
										or pokemon.boosts[attackStat]
									local defBoosts = moveData.useSourceDefensive and pokemon.boosts[defenseStat]
										or target.boosts[defenseStat]
									if
										moveData.ignoreOffensive
										or (moveData.ignoreNegativeOffensive and atkBoosts < 0)
									then
										atkBoosts = 0
									end
									if
										moveData.ignoreDefensive
										or (moveData.ignorePositiveDefensive and defBoosts > 0)
									then
										defBoosts = 0
									end

									if moveData.useTargetOffensive then
										attack = target:calculateStat(attackStat, atkBoosts)
									else
										attack = pokemon:calculateStat(attackStat, atkBoosts)
									end

									if moveData.useSourceDefensive then
										defense = pokemon:calculateStat(defenseStat, defBoosts)
									else
										defense = target:calculateStat(defenseStat, defBoosts)
									end

									local effectiveness = 1
									for _, t in pairs(target:getTypes()) do
										effectiveness = effectiveness * (battle.data.TypeChart[t][moveData.type] or 1)
									end
									local maxDamage = math.floor(
										math.floor(
											math.floor(2 * level / 5 + 2) * effectiveBaseDamage * attack / defense
										) / 50
									) + 2
									maxDamage = math.floor(maxDamage * effectiveness)
									local minDamage = math.floor(0.85 * maxDamage)
								end
								estDamage[m] = maxDamage + (minDamage - maxDamage) * d_alpha
							end
						end
					end
					-- check if there are moves that can (estimatedly) KO the opponent
					local movesThatCouldKO = {}
					local hp = target.hp
					for _, m in pairs(enabledMoves) do
						if estDamage[m] > hp then
							table.insert(movesThatCouldKO, m)
						end
					end
					if #movesThatCouldKO > 0 and math.random(4) < difficulty + 1 then
						if #movesThatCouldKO > 1 then
							-- sort
							-- for now, it only bases it on what has most PP
							table.sort(movesThatCouldKO, function(a, b)
								return pokemon.moveset[a].pp > pokemon.moveset[b].pp
							end)
						end
						move = movesThatCouldKO[1]
					end
					-- set damaging moves' chances
					for _, m in pairs(enabledMoves) do
						if estDamage[m] > 0 then
							local pko = estDamage[m] / hp
							chance[m] = math.max(0, (pko - 0.25) * 4 + 1)
						end
					end
					-- choose random move based on determined chance
					for _, c in pairs(chance) do
						-- make sure there is at least one value > 0
						if c > 0 then
							move = weightedRandom({ 1, 2, 3, 4 }, function(i)
								return chance[i]
							end)
							break
						end
					end
					-- if selected move is Solar Beam AND you know Sunny Day AND it's not already sunny, USE Sunny Day!
					if pokemon.moves[move] == "solarbeam" and not battle:isWeather({ "sunnyday", "desolateland" }) then
						for _, m in pairs(enabledMoves) do
							if pokemon.moves[m] == "sunnyday" then
								move = m
							end
						end
					end
					-- TODO: detect when you can't damage opponent and switch pokemon
				end
			end)
			if not s then
				print("NPC Battle AI encountered error:", r)
			end
		end
		-- default to random move if nothing else
		if not move then
			move = enabledMoves[math.random(#enabledMoves)]
		end
		--
		choices[n] = "move " .. move .. mega
	end
	self.battle:choose(nil, self.id, choices, self.battle.rqid)
end

function Side:Destroy() end

return Side

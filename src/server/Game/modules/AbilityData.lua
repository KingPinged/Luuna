return {
	noability = {
		isNonstandard = "Past",
		name = "No Ability",
		num = 0,
	},
	adaptability = {
		onModifyMove = function(move)
			move.stab = 2
		end,
		name = "Adaptability",
		num = 91,
	},
	aerilate = {
		onModifyTypePriority = -1,
		onModifyType = function(self, move, pokemon)
			local noModifyType = {
				"judgment",
				"multiattack",
				"naturalgift",
				"revelationdance",
				"technoblast",
				"terrainpulse",
				"weatherball",
			}
			if
				move.type == "Normal"
				and (not table.find(noModifyType, move.id))
				and not (move.isZ and move.category ~= "Status")
				and not (move.name == "Tera Blast" and pokemon.terastallized)
			then
				move.type = "Flying"
				move.typeChangerBoosted = self.effect
			end
		end,
		onBasePowerPriority = 23,
		onBasePower = function(self, basePower, pokemon, target, move)
			if move.typeChangerBoosted == self.effect then
				return self.chainModify({ 5325, 4096 })
			end
		end,
		name = "Aerilate",
		num = 184,
	},
	aftermath = {
		name = "Aftermath",
		onDamagingHitOrder = 1,
		onDamagingHit = function(self, damage, target, source, move)
			if not target.hp and self.checkMoveMakesContact(move, source, target, true) then
				self.damage(source.baseMaxhp / 4, source, target)
			end
		end,
		rating = 2,
		num = 106,
	},
	airlock = {
		onSwitchIn = function(self, pokemon)
			self.effectState.switchingIn = true
		end,
		onStart = function(self, pokemon)
			-- Air Lock does not activate when Skill Swapped or when Neutralizing Gas leaves the field
			if self.effectState.switchingIn then
				self.add("-ability", pokemon, "Air Lock")
				self.effectState.switchingIn = false
			end
			self.eachEvent("WeatherChange", self.effect)
		end,
		onEnd = function(self, pokemon)
			self.eachEvent("WeatherChange", self.effect)
		end,
		suppressWeather = true,
		name = "Air Lock",
		rating = 1.5,
		num = 76,
	},
	analytic = {
		onBasePowerPriority = 21,
		onBasePower = function(self, basePower, pokemon)
			local boosted = true
			for i, target in ipairs(self.getAllActive()) do
				if target == pokemon then
					continue
				end
				if self.queue.willMove(target) then
					boosted = false
					break
				end
			end
			if boosted then
				self.debug("Analytic boost")
				return self.chainModify({ 5325, 4096 })
			end
		end,
		name = "Analytic",
		rating = 2.5,
		num = 148,
	},
}

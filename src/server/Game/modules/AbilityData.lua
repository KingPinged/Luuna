return {
    noability: {
		isNonstandard: "Past",
		name: "No Ability",
		rating: 0.1,
		num: 0,
	},
	adaptability: {
		onModifyMove(move) {
			move.stab = 2;
		},
		name: "Adaptability",
		rating: 4,
		num: 91,
	},
	aerilate: {
		onModifyTypePriority: -1,
		onModifyType(move, pokemon) {
			const noModifyType = [
				'judgment', 'multiattack', 'naturalgift', 'revelationdance', 'technoblast', 'terrainpulse', 'weatherball',
			];
			if (move.type === 'Normal' && !noModifyType.includes(move.id) &&
				!(move.isZ && move.category !== 'Status') && !(move.name === 'Tera Blast' && pokemon.terastallized)) {
				move.type = 'Flying';
				move.typeChangerBoosted = this.effect;
			}
		},
		onBasePowerPriority: 23,
		onBasePower(basePower, pokemon, target, move) {
			if (move.typeChangerBoosted === this.effect) return this.chainModify([4915, 4096]);
		},
		name: "Aerilate",
		rating: 4,
		num: 184,
	},
	aftermath: {
		name: "Aftermath",
		onDamagingHitOrder: 1,
		onDamagingHit(damage, target, source, move) {
			if (!target.hp && this.checkMoveMakesContact(move, source, target, true)) {
				this.damage(source.baseMaxhp / 4, source, target);
			}
		},
		rating: 2,
		num: 106,
	},
	airlock: {
		onSwitchIn(pokemon) {
			this.effectState.switchingIn = true;
		},
		onStart(pokemon) {
			// Air Lock does not activate when Skill Swapped or when Neutralizing Gas leaves the field
			if (this.effectState.switchingIn) {
				this.add('-ability', pokemon, 'Air Lock');
				this.effectState.switchingIn = false;
			}
			this.eachEvent('WeatherChange', this.effect);
		},
		onEnd(pokemon) {
			this.eachEvent('WeatherChange', this.effect);
		},
		suppressWeather: true,
		name: "Air Lock",
		rating: 1.5,
		num: 76,
	},
	analytic: {
		onBasePowerPriority: 21,
		onBasePower(basePower, pokemon) {
			let boosted = true;
			for (const target of this.getAllActive()) {
				if (target === pokemon) continue;
				if (this.queue.willMove(target)) {
					boosted = false;
					break;
				}
			}
			if (boosted) {
				this.debug('Analytic boost');
				return this.chainModify([5325, 4096]);
			}
		},
		name: "Analytic",
		rating: 2.5,
		num: 148,
	},
}
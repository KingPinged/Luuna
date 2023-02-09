return {
	version = "0.0.1", -- the version of the game
	lobbyPlaceId = 12370590123,
	gamePLaceId = 12370961507,
	maxTeleportTries = 10,
	maxModerationTries = 20,
	startingTime = 1674542319, -- the time that the custom calendar starts at in Unix epoch format
	dataTemplate = { -- the default data object for the database
		banData = { isBanned = false, banExpires = 0, banReasons = {} },
		saveData = {}, --future proof saves for different profiles of same account, ATM only one profile per account
		settings = {},
	},
	saveTemplate = {},
}

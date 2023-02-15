local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnumList = require(ReplicatedStorage.Packages.EnumList)

local types = EnumList.new("Types", {
	"fire",
	"water",
	"ground",
	"earth",
    "nature"
})

return {
	flitten = {
		name = "flitten",
		type = types.fire,
		id = 1,
		stats = {
            "health" = 100,
            "attack" = 30,
            "speed" = 20,
            "defense" = 30,
            "rangedAttack" = 30,
            "rangedDefense" = 20
        },
	},
    darkin = {
        name = "darkin",
        type = types.fire,
        id = 2,
        stats = {
            "health" = 100,
            "attack" = 30,
            "speed" = 20,
            "defense" = 30,
            "rangedAttack" = 30,
            "rangedDefense" = 20
        },
    },
    junior = {
        name = "junior",
        type = types.fire,
        id = 3,
        stats = {
            "health" = 100,
            "attack" = 30,
            "speed" = 20,
            "defense" = 30,
            "rangedAttack" = 30,
            "rangedDefense" = 20
        },
    
    }
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnumList = require(ReplicatedStorage.Packages.EnumList)

local types = EnumList.new("Types", {
	"fire",
	"water",
	"ground",
	"earth",
    "nature",
    "dark",
    "dragon",
    "electric"
})

return {
	flitten = {
		name = "flitten",
		type = types.fire,
		id = 1,
		baesStats = {
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
        baesStats = {
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
        baesStats = {
            "health" = 100,
            "attack" = 30,
            "speed" = 20,
            "defense" = 30,
            "rangedAttack" = 30,
            "rangedDefense" = 20
        },
    
    },
    bunbun = {
        name = "bunbun"
        type = types.water,
        id = 4,
        baesStats = {
            "health" = 100,
            "attack" = 30,
            "speed" = 20,
            "defense" = 30,
            "rangedAttack" = 30,
            "rangedDefense" = 20
        },
    },
    shady = {
        name = "shady",
        type = types.nature,
        id = 6,
        baesStats = {
            "health" = 100,
            "attack" = 30,
            "speed" = 20,
            "defense" = 30,
            "rangedAttack" = 30,
            "rangedDefense" = 20
        },
    },
    shilly = {
        name = "shilly",
        type = types.earth,
        id = 7,
        baesStats = {
            "health" = 100,
            "attack" = 30,
            "speed" = 20,
            "defense" = 30,
            "rangedAttack" = 30,
            "rangedDefense" = 20
        },
    }
}

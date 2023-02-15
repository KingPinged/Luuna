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
    types.fire = {
        "weak" = type.water,
        "strong" = type.nature,
    },
    types.water = {
        "weak" = type.ground,
        "strong" = type.earth,
    },
    types.ground = {
        "weak" = type.ground,
        "strong" = type.ground,
    },
    types.earth = {
        "weak" = type.earth,
        "strong" = type.earth,
    },
    types.nature = {
        "weak" = type.nature,
        "strong" = type.nature,
    },

}

local BattleActions = {}
BattleActions.__index = BattleActions

function BattleActions.new()
	local self = setmetatable({}, BattleActions)
	return self
end

function BattleActions:Destroy(): () end

return BattleActions

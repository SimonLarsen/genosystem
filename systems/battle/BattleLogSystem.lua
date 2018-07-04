--- Battle log system.
-- @classmod system.battle.BattleLogSystem
local BattleLogSystem = class("systems.battle.BattleLogSystem", System)

function BattleLogSystem:initialize()
    System.initialize(self)
end

function BattleLogSystem:requires()
    return {"components.battle.BattleLog"}
end

function BattleLogSystem:update(dt)
    for _, e in pairs(self.targets) do
    end
end

return BattleLogSystem

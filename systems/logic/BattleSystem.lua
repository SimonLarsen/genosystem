--- In-battle system.
-- @classmod systems.logic.BattleSystem
local BattleSystem = class("systems.logic.BattleSystem", System)

function BattleSystem:initialize()
    System.initialize(self)
end

function BattleSystem:update(dt)
    for _, battle in pairs(self.targets) do
        -- start of battle
        if battle.turn_party == 0 then
            battle.turn_party = 1
            battle.turn_player = 1
        end
    end
end

function BattleSystem:requires()
    return {"components.battle.Battle"}
end

return BattleSystem

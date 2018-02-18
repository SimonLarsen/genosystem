--- Battle state component
-- @classmod components.battle.Battle
local Battle = class("components.battle.Battle")

--- Constructor.
-- @param party1 Table of player entities for first party.
-- @param party2 Table of player entities for second party.
function Battle:initialize(party1, party2)
    self.party1 = party1
    self.party2 = party2

    self.turn_party = 0 -- 0 for no turn yet
    self.turn_player = 0
end

return Battle

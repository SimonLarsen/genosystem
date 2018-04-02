--- Battle state component
-- @classmod components.battle.Battle
local Battle = class("components.battle.Battle")

Battle.static.STATE_INIT    = 0
Battle.static.STATE_PREPARE = 1
Battle.static.STATE_PLAY    = 2
Battle.static.STATE_RESOLVE = 3
Battle.static.STATE_TARGET  = 4

--- Constructor.
-- @param party1 Table of player entities for first party.
-- @param party2 Table of player entities for second party.
-- @param card_index Table of all @{cards.Card} definitions.
function Battle:initialize(party1, party2, card_index, hand)
    self.party = {party1, party2}

    self.card_index = card_index

    self.state = Battle.static.STATE_INIT
    self.current_party = 1
    self.current_player = 1
    self.actions = 0
    self.effects = {}
    self.hand = hand
end

function Battle:currentPlayer()
    return self.party[self.current_party][self.current_player]
end

function Battle:currentParty()
    return self.party[self.current_party]
end

return Battle

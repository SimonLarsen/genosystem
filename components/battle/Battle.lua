--- Battle state component
-- @classmod components.battle.Battle
local Battle = class("components.battle.Battle")

Battle.static.STATE_INIT      = 0
Battle.static.STATE_PREPARE   = 1
Battle.static.STATE_PLAY_CARD = 2
Battle.static.STATE_RESOLVE   = 3
Battle.static.STATE_TARGET    = 4

Battle.static.PHASE_ACTIVE   = 0
Battle.static.PHASE_REACTIVE = 1

--- Constructor.
-- @param party1 Table of player entities for first party.
-- @param party2 Table of player entities for second party.
-- @param card_index Table of all @{cards.Card} definitions.
-- @param hand Entity of current battle.
function Battle:initialize(player1, player2, hand1, hand2, card_index)
    self.players = {player1, player2}
    self.hands = {hand1, hand2}

    self.card_index = card_index

    self.state = Battle.static.STATE_INIT
    self.phase = Battle.static.PHASE_ACTIVE
    self.current_player = 1
    self.effects = {}
end

function Battle:currentPlayer()
    return self.players[self.current_player]
end

function Battle:currentHand()
    return self.hands[self.current_player]
end

return Battle

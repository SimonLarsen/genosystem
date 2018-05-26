--- Battle state component
-- @classmod components.battle.Battle
local Battle = class("components.battle.Battle")

Battle.static.STATE_INIT          = 0
Battle.static.STATE_PREPARE       = 1
Battle.static.STATE_PLAY_CARD     = 2
Battle.static.STATE_REACT         = 3
Battle.static.STATE_RESOLVE       = 4
Battle.static.STATE_REACT_DAMAGE  = 5
Battle.static.STATE_REACT_RESOLVE = 6

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
    self.actions = 0
    self.damage = 0
    self.effects = {}
    self.react_effects = {}
end

function Battle:currentPlayer()
    return self.players[self.current_player]
end

function Battle:opponentPlayer()
    return self.players[self.current_player % 2 + 1]
end

function Battle:currentHand()
    return self.hands[self.current_player]
end

function Battle:opponentHand()
    return self.hands[self.current_player % 2 + 1]
end

return Battle

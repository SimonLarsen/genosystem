--- Battle state component
-- @classmod components.battle.Battle
local Battle = class("components.battle.Battle")

Battle.static.STATE_INIT         = 0
Battle.static.STATE_PREPARE      = 1
Battle.static.STATE_PLAY         = 2
Battle.static.STATE_REACT        = 3
Battle.static.STATE_REACT_DAMAGE = 4

--- Constructor.
-- @param player1 First @{components.battle.Player} instance.
-- @param player2 Second @{components.battle.Player} instance.
-- @param hand1 @{components.battle.Hand} instance for first player.
-- @param hand2 @{components.battle.Hand} instance for second player.
-- @param card_index Table of all cards.
function Battle:initialize(player1, player2, hand1, hand2, card_index)
    self.players = {player1, player2}
    self.hands = {hand1, hand2}

    self.card_index = card_index

    self.state = Battle.static.STATE_INIT
    self.phase = Battle.static.PHASE_ACTIVE
    self.current_player = 1
    self.actions = 0
    self.damage = 0
    self.wait = 0
    self.effects = {}
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

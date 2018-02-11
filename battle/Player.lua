--- In-battle Player class.
-- @classmod battle.Player
local Player = class("battle.Player")

local HAND_SIZE = 5

--- Constructor.
-- @param deck Player deck. Table of @{cards.Card} objects
function Player:initialize(deck)
    self.hand = {}
    self.discard = {}
    self.wounded = {}
    self.deck = prox.table.copy(deck)

    prox.table.shuffle(self.deck)

    for i=1,HAND_SIZE do
        self:draw()
    end
end

--- Draw a card from deck.
function Player:draw()
    if #self.deck == 0 then
        self:shuffle()
    end
    if #self.deck == 0 then
        return false
    end
    table.insert(self.hand, self.deck[1])
    table.remove(self.deck, 1)
    return true
end

--- Discard a card from hand.
-- @param i Index in hand to discard.
function Player:discard(i)
    if not self.hand[i]:isToken() then
        table.insert(self.discard, self.hand[i])
    end
    table.remove(self.hand, i)
end

--- Shuffle all cards from discard pile into deck.
function Player:shuffle()
    self.deck = self.discard
    self.discard = {}
    prox.table.shuffle(self.deck)
end

--- Play card in hand.
-- @param i Index of card to play
-- @param cards Database of @{cards.Card} instances
-- @param variables Table of current battle variables
-- @param events (Output) Table to return events.
function Player:playCard(i, cards, variables, events)
    assert(i >= 1 and i <= #self.hand, "Card index out of range")
    cards[self.hand[i].id]:play(variables, events)
    return events
end

--- Deal damage to player.
-- @param dmg Amount to damage to deal.
function Player:damage(dmg)
    while #self.hand > 0 and dmg > 0 do
        local discard_index = love.math.random(1, #self.hand)
        self:discard(discard_index)
        dmg = dmg - 1
    end
end

--- Deal one wound to player.
-- Moves one card from top of deck to wound pile. Reshuffles if necessary.
function Player:wound()
    if #self.deck == 0 then
        self:shuffle()
    end
    assert(#self.deck > 0, "Player death not implemented.")
    table.insert(self.wounded, self.deck[1])
    table.remove(self.deck, 1)
end

--- Deal token `card` to player in target pile `pile`.
-- @param card @{cards.Card} instance to deal
-- @param pile Target pile to deal card to
function Player:deal(card, pile)
    if pile == "hand" then
        table.insert(self.hand, card)
    elseif pile == "deck" then
        table.insert(self.deck, card)
        prox.table.shuffle(self.deck)
    elseif pile == "discard" then
        table.insert(self.discard, card)
    else
        error(string.format("Unknown pile \"%s\".", pile))
    end
end

return Player

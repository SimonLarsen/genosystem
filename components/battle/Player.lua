--- In-battle Player component.
-- @classmod components.battle.Player
local Player = class("components.battle.Player")

local Pile = require("battle.Pile")

--- Constructor.
-- @param name Display name of the player.
-- @param deck Player deck. Table of @{cards.Card} objects
function Player:initialize(name, deck)
    self.name = name

    self.hand = {}
    self.react = {}
    self.discard = {}
    self.deck = {}
    self.alive = true

    for i,v in pairs(deck) do
        table.insert(self.deck, v)
    end

    prox.table.shuffle(self.deck)
end

--- Draw a card from deck to hand. Shuffles discard pile if necessary.
-- @return True if drawing was possible, false otherwise
function Player:draw()
    if #self.deck == 0 then
        return nil
    end
    local c = self.deck[1]
    table.remove(self.deck, 1)
    table.insert(self.hand, c)
    return c
end

--- Discard a card from hand to discard pile.
-- @param i Card to discard. Chooses randomly if not given.
-- @return True if discard was possible, false otherwise.
function Player:discardCard(i)
    if #self.hand == 0 then
        return nil
    end
    i = i or love.math.random(1, #self.hand)

    local card = self.hand[i]
    table.remove(self.hand, i)
    table.insert(self.discard, 1, card)
    return card
end

function Player:hit(i)
    if #self.hand == 0 then
        self.alive = false
        return nil
    end
    i = i or love.math.random(1, #self.hand)

    local card = self.hand[i]
    table.remove(self.hand, i)
    table.insert(self.discard, 1, card)

    if #card.reactive > 0 then
        table.insert(self.react, card)
    end

    return i
end

return Player

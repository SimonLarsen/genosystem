--- In-battle Player component.
-- @classmod components.battle.Player
local Player = class("components.battle.Player")

local Pile = require("battle.Pile")

--- Constructor.
-- @param id Index of player {1,2}
-- @param name Display name of the player
-- @param deck Player deck. Table of @{core.Card} objects
-- @param gear Player gear. A table of @{core.Gear} objects
-- @param ai AI components if player is non-player controlled
function Player:initialize(id, name, deck, gear, ai)
    self.id = id
    self.name = name

    self.hand = {}
    self.discard = {}
    self.deck = {}
    self.gear = {}
    self.alive = true
    self.ai = ai

    for i,v in pairs(deck) do
        table.insert(self.deck, v)
    end

    for i,v in pairs(gear) do
        table.insert(self.gear, {revealed=false, damage=0, destroyed=false, item=v})
    end

    prox.table.shuffle(self.deck)
end

--- Draw a card from deck to hand. Shuffles discard pile if necessary.
-- @return True if drawing was possible, false otherwise
function Player:draw()
    if #self.deck == 0 then
        self.deck = self.discard
        self.discard = {}
        prox.table.shuffle(self.deck)
    end
    if #self.deck == 0 then
        return nil
    end
    local c = self.deck[1]
    table.remove(self.deck, 1)
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

--- Get top gear slot.
-- @return Return gear slot table. Returns `nil` if all gear is destroyed.
function Player:currentGear()
    for i,v in ipairs(self.gear) do
        if not v.destroyed then
            return v
        end
    end
end

function Player:isAI()
    return self.ai ~= nil
end

return Player

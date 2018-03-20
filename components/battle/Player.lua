--- In-battle Player component.
-- @classmod components.battle.Player
local Player = class("components.battle.Player")

local Pile = require("battle.Pile")

--- Constructor.
-- @param name Display name of the player.
-- @param deck Player deck. Table of @{cards.Card} objects
function Player:initialize(name, deck)
    self.name = name

    self.hand = Pile()
    self.discard = Pile()
    self.wounded = Pile()
    self.deck = Pile(deck)

    self.deck:shuffle()
end

function Player:draw()
    if self.deck:size() == 0 then
        self:shuffle()
    end
    if self.deck:size() == 0 then
        return false
    end
    local c = self.deck:draw()
    self.hand:addCard(c)
    return true
end

function Player:shuffle()
    assert(self.deck:size() == 0, "Cannot shuffle when deck is not empty.")

    self.deck:addCards(self.discard:getCards())
    self.deck:shuffle()
    self.discard:clear()
end

function Player:hit()
    if self.hand:size() > 0 then
        local card_index = love.math.random(1, self.hand:size())
        local card = self.hand:draw(card_index)
        self.discard:addCard(card)
    else
        if self.deck:size() == 0 then
            self.shuffle()
        end
        if self.deck:size() > 0 then
            local card = self.deck:draw()
            self.wounded:addCard(card)
        else
            print("Dead!")
        end
    end
end

return Player

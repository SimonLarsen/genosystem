--- In-battle Player component.
-- @classmod components.battle.Player
local Player = class("components.battle.Player")

local Pile = require("battle.Pile")

local HAND_SIZE = 5

--- Constructor.
-- @param deck Player deck. Table of @{cards.Card} objects
function Player:initialize(deck)
    self.hand = {}
    self.discard = Pile()
    self.wounded = Pile()
    self.deck = Pile(deck)

    self.deck:shuffle()
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

return Player

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

--- Draw a card from deck to hand. Shuffles discard pile if necessary.
-- @param return True if drawing was possible, false otherwise
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

--- Shuffles discard into deck.
function Player:shuffle()
    assert(self.deck:size() == 0, "Cannot shuffle when deck is not empty.")

    self.deck:addCards(self.discard:getCards())
    self.deck:shuffle()
    self.discard:clear()
end

--- Give player one hit. Takes card from hand to discard. If hand is empty, top card in deck is wounded instead.
function Player:hit()
    if self.hand:size() > 0 then
        local decoys = {}
        for i,v in ipairs(self.hand:getCards()) do
            if v:isDecoy() then
                table.insert(decoys, v)
            end
        end
        local card
        if #decoys > 0 then
            card = decoys[love.math.random(1, #decoys)]
        else
            local card_index = love.math.random(1, self.hand:size())
            card = self.hand:draw(card_index)
        end
        self.discard:addCard(card)
    else
        if self.deck:size() == 0 then
            self:shuffle()
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

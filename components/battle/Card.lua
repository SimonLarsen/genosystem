--- In-battle card component.
-- @classmod components.battle.Card

local Card = class("components.battle.Card")

function Card:initialize(card, x, y)
    self.card = card
    self.targetx = x or 0
    self.targety = y or 0
end

return Card

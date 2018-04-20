--- In-battle card component.
-- @classmod components.battle.Card

local Card = class("components.battle.Card")

function Card:initialize(card, x, y)
    self.card = card
    self.target = prox.Transform(0, 0)
end

return Card

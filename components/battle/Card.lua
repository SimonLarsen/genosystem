--- In-battle card component.
-- @classmod components.battle.Card

local Card = class("components.battle.Card")

function Card:initialize(card)
    self.card = card
    self.target = prox.Transform(0, 0)
    self.dir = 0
    self.target_dir = 0
end

return Card

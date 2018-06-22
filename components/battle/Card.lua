--- In-battle card component.
-- @classmod components.battle.Card

local Card = class("components.battle.Card")

function Card:initialize(card, dir, zoom, active)
    self.card = card
    self.dir = dir or 0
    self.zoom = zoom or 1
    self.active = active ~= false
    self.alive = 1
end

return Card

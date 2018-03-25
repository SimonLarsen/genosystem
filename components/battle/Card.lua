--- In-battle card component.
-- @classmod components.battle.Card

local Card = class("components.battle.Card")

function Card:initialize(id)
    self.id = id
    self.image = AssetManager.getCard(self.id)
end

return Card

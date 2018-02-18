--- Card effect queue object.
-- @classmod cards.CardEffect
local CardEffect = class("cards.CardEffect")

function CardEffect:initialize(target, effect)
    self.target = target
    self.effect = effect
end

return CardEffect

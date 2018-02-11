--- Card effect dealing damage
-- @classmod cards.effects.Hit

local Hit = class("cards.effects.Hit")

function Hit:initialize(count)
    self.count = count
end

function Hit:getType()
    return "hit"
end

function Hit:apply(target)
    target:damage(self.count)
end

return Hit

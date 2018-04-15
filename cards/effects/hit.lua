--- Card effect dealing damage
-- @classmod cards.effects.Hit

local Hit = class("cards.effects.Hit")

function Hit:initialize(count)
    self.type = "hit"
    self.count = count
end

function Hit:getText()
    return string.format("Deal %d damage", self.count)
end

function Hit:clone()
    return Hit(self.count)
end

return Hit

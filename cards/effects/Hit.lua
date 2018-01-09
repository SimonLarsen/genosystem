local Hit = class("cards.effects.Hit")

function Hit:initialize(count)
    self.count = count
end

function Hit:getType()
    return "hit"
end

return Hit

local Hit = class("cards.effects.Hit")

function Hit:initialize(count)
    self.count = count
end

function Hit:getType()
    return "hit"
end

function Hit:apply(targets)
    for i,v in ipairs(targets) do
        v:damage(self.count)
    end
end

return Hit

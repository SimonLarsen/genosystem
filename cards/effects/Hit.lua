--- Card effect dealing damage
-- @classmod cards.effects.Hit

local Hit = class("cards.effects.Hit")

function Hit:initialize(count)
    self.count = count
end

function Hit:getType()
    return "hit"
end

function Hit:apply(targets, card_index)
    for _,v in ipairs(targets) do
        for i=1,self.count do
            v:hit()
        end
    end
end

return Hit

--- Card effect drawing cards
-- @classmod cards.effects.Draw
local Draw = class("cards.effects.Draw")

function Draw:initialize(count)
    self.count = count
end

function Draw:getType()
    return "draw"
end

function Draw:apply(targets)
    for _,v in ipairs(targets) do
        for i=1,self.count do
            v:draw()
        end
    end
end

return Draw

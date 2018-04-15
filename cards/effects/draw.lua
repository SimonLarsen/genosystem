--- Card effect drawing cards
-- @classmod cards.effects.Draw
local Draw = class("cards.effects.Draw")

function Draw:initialize(count)
    self.type = "draw"
    self.count = count
end

function Draw:getText()
    return string.format("Draw %d card(s)", self.count)
end

function Draw:clone()
    return Draw(self.count)
end

return Draw

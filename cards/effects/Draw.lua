local Draw = class("cards.effects.Draw")

function Draw:initialize(count)
    self.count = count
end

function Draw:getType()
    return "draw"
end

return Draw
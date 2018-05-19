--- Card effect discarding from hand
-- @classmod cards.effects.Discard
local Discard = class("cards.effect.Discard")

function Discard:initialize(count)
    self.type = "discard"
    self.count = count
end

function Discard:getText()
    return string.format("Discard %d cards", self.count)
end

function Discard:clone()
    return Discard(self.count)
end

return Discard

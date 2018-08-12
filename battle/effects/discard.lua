--- Effect discarding from hand
-- @classmod battle.effects.Discard
local Discard = class("battle.effect.Discard")

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

--- Card effect gaining new actions
-- @classmod cards.effects.GainAction

local GainAction = class("cards.effects.GainAction")

function GainAction:initialize(count)
    self.type = "gainaction"
    self.count = count
end

function GainAction:getText()
    string.format("Gain %d actions", self.count)
end

function GainAction:clone()
    return GainAction(self.count)
end

return GainAction

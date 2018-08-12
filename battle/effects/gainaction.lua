--- Effect gaining new actions
-- @classmod battle.effects.GainAction

local GainAction = class("battle.effects.GainAction")

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

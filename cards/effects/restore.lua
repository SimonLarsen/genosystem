--- Card effect restoring wounded cards
-- @classmod cards.effects.Restore
local Restore = class("cards.effects.Restore")

function Restore:initialize(count)
    self.type = "restore"
    self.count = count
end

function Restore:getText()
    return string.format("Restore %d wounded cards", self.count)
end

function Restore:clone()
    return Restore(self.count)
end

return Restore

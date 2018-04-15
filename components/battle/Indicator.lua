local Indicator = class("components.battle.Indicator")

Indicator.static.TYPE_DAMAGE = 0
Indicator.static.TYPE_DRAW   = 1

function Indicator:initialize(type, value)
    self.type = type
    self.value = value
    self.time = 1.5
end

return Indicator

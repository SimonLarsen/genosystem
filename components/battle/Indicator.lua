--- In-battle effect indicator component.
-- @classmod components.battle.Indicator
local Indicator = class("components.battle.Indicator")

Indicator.static.TYPE_DAMAGE = 0
Indicator.static.TYPE_DRAW   = 1
Indicator.static.TYPE_DEAL   = 2

function Indicator:initialize(type, time, value, token)
    self.type = type
    self.value = value
    self.time = time
    self.alpha = 1
    self.token = token
end

return Indicator

--- In-battle effect indicator component.
-- @classmod components.battle.Indicator
local Indicator = class("components.battle.Indicator")

Indicator.static.TYPE_DAMAGE      = 0
Indicator.static.TYPE_DRAW        = 1
Indicator.static.TYPE_DEAL        = 2
Indicator.static.TYPE_DISCARD     = 3
Indicator.static.TYPE_RESTORE     = 4
Indicator.static.TYPE_GAIN_ACTION = 5

function Indicator:initialize(type, time, value, token)
    self.type = type
    self.value = value
    self.time = time
    self.alpha = 1
    self.token = token
end

return Indicator

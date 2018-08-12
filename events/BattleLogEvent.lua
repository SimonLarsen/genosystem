--- Battle log message event.
-- @classmod events.BattleLogEvent
local BattleLogEvent = class("events.BattleLogEvent")

--- Constructor.
-- @param text Log message. String or table.
function BattleLogEvent:initialize(text)
    self.text = text
end

return BattleLogEvent

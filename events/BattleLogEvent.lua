--- Battle log message event.
-- @classmod events.BattleLogEvent
local BattleLogEvent = class("events.BattleLogEvent")

--- Constructor.
-- @param text Log message. String or table.
function BattleLogEvent:initialize(text, describe_type, describe_id)
    self.text = text
    self.describe_type = describe_type
    self.describe_id = describe_id
end

return BattleLogEvent

local BattleLogEvent = class("events.BattleLogEvent")

function BattleLogEvent:initialize(text)
    self.text = text
end

return BattleLogEvent

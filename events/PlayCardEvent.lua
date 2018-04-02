local PlayCardEvent = class("events.PlayCardEvent")

function PlayCardEvent:initialize(card)
    self.card = card
end

return PlayCardEvent

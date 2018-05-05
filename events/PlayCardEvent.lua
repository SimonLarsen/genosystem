local PlayCardEvent = class("events.PlayCardEvent")

function PlayCardEvent:initialize(player, card)
    self.player = player
    self.card = card
end

return PlayCardEvent

local DrawCardEvent = class("events.DrawCardEvent")

function DrawCardEvent:initialize(party, player, card)
    self.party = party
    self.player = player
    self.card = card
end

return DrawCardEvent

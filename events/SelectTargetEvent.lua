local SelectTargetEvent = class("events.SelectTargetEvent")

function SelectTargetEvent:initialize(party, player)
    self.party = party
    self.player = player
end

return SelectTargetEvent

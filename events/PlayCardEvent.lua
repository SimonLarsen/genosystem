--- Card selected for play event.
-- @classmod events.PlayCardEvent
local PlayCardEvent = class("events.PlayCardEvent")

--- Constructor.
-- @param player (number) Player ID
-- @param card (number) Card index in hand
function PlayCardEvent:initialize(player, card)
    self.player = player
    self.card = card
end

return PlayCardEvent

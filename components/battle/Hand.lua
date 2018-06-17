--- In-battle hand component
-- @classmod components.battle.Hand
local Hand = class("components.battle.Hand")

local Pile = require("battle.Pile")

Hand.static.STATE_INACTIVE = 1
Hand.static.STATE_ACTIVE   = 2
Hand.static.STATE_REACT    = 3

--- Constructor
-- @param player ID of player hand belongs to {1,2}
function Hand:initialize(player)
    self.cards = {}
    self.player = player
    self.state = Hand.static.STATE_INACTIVE
end

return Hand

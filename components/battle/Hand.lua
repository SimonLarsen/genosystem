--- In-battle hand component
-- @classmod components.battle.Hand
local Hand = class("components.battle.Hand")

local Pile = require("battle.Pile")

function Hand:initialize(player)
    self.cards = {}
    self.player = player
end

return Hand

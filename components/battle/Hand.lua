--- In-battle hand component
-- @classmod components.battle.Hand

local Hand = class("components.battle.Hand")

local Pile = require("battle.Pile")

function Hand:initialize()
    self.cards = {}
end

return Hand

--- Unconditional card action
-- @classmod cards.Action
local Action = class("cards.Action")

local TargetEffect = require("cards.TargetEffect")
local CardEffect = require("cards.CardEffect")

--- Constructor.
-- @param target (string) Target of action.
-- @param effects (table) Effects.
function Action:initialize(target, effects)
    self.target = target
    self.effects = effects
end

--- Recursively apply card action, adding effects to queue.
-- @param variables Table of current battle variables.
-- @param effects Effect queue.
-- @return The effects queue.
function Action:apply(variables, effects)
    if self.target == "target" then
        table.insert(effects, TargetEffect())
    end
    for i,v in ipairs(self.effects) do
        table.insert(effects, CardEffect(self.target, v))
    end
    return effects
end

return Action

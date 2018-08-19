--- Unconditional card action
-- @classmod battle.Action
local Action = class("battle.Action")

local Effect = require("battle.Effect")

--- Constructor.
-- @param target (string) Target of action.
-- @param effects (table) Effects.
function Action:initialize(target, effects)
    self.target = target
    self.effects = effects
end

--- Recursively apply card action, adding effects to queue.
-- @param variables Table of current battle variables.
-- @param targets Table of player targets.
-- @param can_react True if this effect triggers reactive effects.
-- @param effects Effect queue.
-- @return The effects queue.
function Action:apply(variables, targets, can_react, effects)
    for i,v in ipairs(self.effects) do
        table.insert(effects, Effect(targets[self.target], can_react, v:clone()))
    end
    return effects
end

return Action

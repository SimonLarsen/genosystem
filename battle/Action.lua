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
-- @param reactive True if effect is applied reactively.
-- @param effects Effect queue.
-- @return The effects queue.
function Action:apply(variables, reactive, effects)
    for i,v in ipairs(self.effects) do
        table.insert(effects, Effect(self.target, reactive, v:clone()))
    end
    return effects
end

return Action

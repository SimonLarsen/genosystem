--- Conditional card action
-- @classmod battle.ConditionalAction

local ConditionalAction = class("battle.ConditionalAction")

--- Constructor.
-- @param condition @{battle.Condition} object.
-- @param ifaction @{battle.Action} to apply if `condition` is true.
-- @param elseaction (optional) @{battle.Action} to apply if `condition` is false.
function ConditionalAction:initialize(condition, ifaction, elseaction)
    self.condition = condition
    self.ifaction = ifaction
    self.elseaction = elseaction
end

--- Recursively apply card actions.
-- @param variables Table of current battle variables.
-- @param targets Table of player targets.
-- @param can_react True if this effect triggers reactive effects.
-- @param effects Effect queue.
-- @return The effects queue.
function ConditionalAction:apply(variables, targets, can_react, effects)
    if self.condition:evaluate(variables) then
        self.ifaction:apply(variables, targets, can_react, effects)
    elseif self.elseaction then
        self.elseaction:apply(variables, targets, can_react, effects)
    end
    return effects
end

return ConditionalAction

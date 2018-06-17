--- Conditional card action
-- @classmod cards.ConditionalAction

local ConditionalAction = class("cards.ConditionalAction")

--- Constructor.
-- @param condition @{cards.Condition} object.
-- @param ifaction @{cards.Action} to apply if `condition` is true.
-- @param elseaction (optional) @{cards.Action} to apply if `condition` is false.
function ConditionalAction:initialize(condition, ifaction, elseaction)
    self.condition = condition
    self.ifaction = ifaction
    self.elseaction = elseaction
end

--- Recursively apply card actions.
-- @param variables Table of current battle variables.
-- @param reactive True if effect is applied reactively.
-- @param effects Effect queue.
-- @return The effects queue.
function ConditionalAction:apply(variables, reactive, effects)
    if self.condition:evaluate(variables) then
        self.ifaction:apply(variables, reactive, effects)
    elseif self.elseaction then
        self.elseaction:apply(variables, reactive, effects)
    end
    return effects
end

return ConditionalAction

--- Effect queue object.
-- @classmod battle.Effect
local Effect = class("battle.Effect")

--- Constructor.
-- @param target (string) Target of action.
-- @param can_react (boolean) True if this effect triggers reactive effects.
-- @param effect Effect to apply.
function Effect:initialize(target, can_react, effect)
    self.target = target
    self.can_react = can_react
    self.effect = effect
end

return Effect

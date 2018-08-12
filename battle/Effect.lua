--- Effect queue object.
-- @classmod battle.Effect
local Effect = class("battle.Effect")

--- Constructor.
-- @param target (string) Target of action.
-- @param reactive True if effect is applied reactively.
-- @param effect Effect to apply.
function Effect:initialize(target, reactive, effect)
    self.target = target
    self.reactive = reactive
    self.effect = effect
end

return Effect

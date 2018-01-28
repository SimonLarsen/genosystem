local ConditionalAction = class("cards.ConditionalAction")

function ConditionalAction:initialize(condition, ifaction, elseaction)
    self.condition = condition
    self.ifaction = ifaction
    self.elseaction = elseaction
end

return ConditionalAction

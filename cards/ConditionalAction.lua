local ConditionalAction = class("cards.ConditionalAction")

function ConditionalAction:initialize(condition, ifaction, elseaction)
    self.condition = condition
    self.ifaction = ifaction
    self.elseaction = elseaction
end

function ConditionalAction:apply(variables, events)
    if self.condition:evaluate(variables) then
        self.ifaction:apply(variables, events)
    else if self.elseaction then
        self.elseaction:apply(variables, events)
    end
    return events
end

return ConditionalAction

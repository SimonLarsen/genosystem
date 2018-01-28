local Condition = class("cards.Condition")

function Condition:initialize(variable, op, value)
    self.variable = variable
    self.op = op
    self.value = value
end

return Condition

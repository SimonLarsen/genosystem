local Condition = class("cards.Condition")

local operators = {
    [">"]  = function(a, b) return a > b end,
    ["<"]  = function(a, b) return a < b end,
    [">="] = function(a, b) return a >= b end,
    ["<="] = function(a, b) return a <= b end,
    ["!="] = function(a, b) return a ~= b end,
    ["=="] = function(a, b) return a == b end
}

function Condition:initialize(variable, op, value)
    self.variable = variable
    self.op = operators[op]
    self.value = value
end

function Condition:evaluate(vars)
    local var = vars[self.variable]
    return self.op(var, self.value)
end

return Condition

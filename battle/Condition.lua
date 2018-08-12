--- Condition for card action
-- @classmod battle.Condition

local Condition = class("battle.Condition")

local operators = {
    [">"]  = function(a, b) return a > b end,
    ["<"]  = function(a, b) return a < b end,
    [">="] = function(a, b) return a >= b end,
    ["<="] = function(a, b) return a <= b end,
    ["!="] = function(a, b) return a ~= b end,
    ["=="] = function(a, b) return a == b end
}

--- Constructor.
-- @param variable Name of condition variable to compare
-- @param op Operator ('>','<','>=','<=','!=','==')
-- @param value Value to compare to
function Condition:initialize(variable, op, value)
    self.variable = variable
    self.op = operators[op]
    self.value = value
end

--- Evaluate condition.
-- @param vars Table of current battle variables
-- @return True if condition is satisfied, false otherwise.
function Condition:evaluate(vars)
    local var = vars[self.variable]
    return self.op(var, self.value)
end

return Condition

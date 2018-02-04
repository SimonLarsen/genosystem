--- Unconditional card action
-- @classmod cards.Action

local Action = class("cards.Action")

--- Constructor.
-- @param target (string) Target of action
-- @param effects (table) Effects
function Action:initialize(target, effects)
    self.target = target
    self.effects = effects
end

--- Recursively apply card action, adding events to queue
-- @param variables Table of current battle variables
-- @param events Event queue
-- @return The event queue
function Action:apply(variables, events)
    for i,v in ipairs(self.effets) do
        table.insert(events, v)
    end
    return events
end

return Action

local Action = class("cards.Action")

function Action:initialize(target, effects)
    self.target = target
    self.effects = effects
end

function Action:apply(variables, events)
    for i,v in ipairs(self.effets) do
        table.insert(events, v)
    end
    return events
end

return Action

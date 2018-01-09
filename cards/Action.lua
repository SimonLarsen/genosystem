local Action = class("cards.Action")

function Action:initialize(target, effects)
    self.target = target
    self.effects = effects
end

return Action

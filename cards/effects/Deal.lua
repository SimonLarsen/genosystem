--- Card effect dealing token cards
-- @classmod cards.effects.Deal

local Deal = class("cards.effects.Deal")

function Deal:initialize(count, card, pile)
    self.count = count
    self.card = card
    self.pile = pile
end

function Deal:getType()
    return "deal"
end

function Deal:apply(target)
    for i=1,self.count do
        target:deal(self.card, self.pile)
    end
end

return Deal

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

function Deal:apply(targets, card_index)
    for _,v in ipairs(targets) do
        for i=1,self.count do
            v[self.pile]:addCard(card_index[self.card])
        end
    end
end

return Deal

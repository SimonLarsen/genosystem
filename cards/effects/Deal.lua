local Deal = class("cards.effects.Deal")

function Deal:initialize(count, card, pile)
    self.count = count
    self.card = card
    self.pile = pile
end

function Deal:getType()
    return "deal"
end

return Deal
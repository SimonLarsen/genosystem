--- Effect dealing token cards
-- @classmod battle.effects.Deal
local Deal = class("battle.effects.Deal")

function Deal:initialize(count, card, pile)
    self.type = "deal"
    self.count = count
    self.card = card
    self.pile = pile
end

function Deal:getText()
    return string.format("Deal %d %s token(s) to %s", self.count, self.card, self.pile)
end

function Deal:clone()
    return Deal(self.count, self.card, self.pile)
end

return Deal

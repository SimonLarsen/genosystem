--- Effect replacing cards in hand with tokens
-- @classmod battle.effects.Replace

local Replace = class("battle.effects.Replace")

function Replace:initialize(count, card)
    self.type = "replace"
    self.count = count
    self.card = card
end

function Replace:getText()
    return string.format("Replace %d cards in hand with %s token", self.count, self.card)
end

function Replace:clone()
    return Replace(self.count, self.card)
end

return Replace

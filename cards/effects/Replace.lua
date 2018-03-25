--- Card effect replacing cards in hand with tokens
-- @classmod cards.effects.Replace

local Replace = class("cards.effects.Replace")

function Replace:initialize(count, card)
    self.count = count
    self.card = card
end

function Replace:getType()
    return "replace"
end

function Replace:apply(targets, card_index)
    for _,v in ipairs(targets) do
        local count = math.min(v.hand:size(), self.count)
        for i=1, count do
            local card = v:discardCard()
        end
        for i=1, count do
            v.hand:addCard(card_index[self.card])
        end
    end
end

return Replace

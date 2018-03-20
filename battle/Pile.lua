local Pile = class("battle.Pile")

function Pile:initialize(cards)
    if cards then
        self._cards = prox.table.copy(cards)
    else
        self._cards = {}
    end
end

function Pile:addCard(card)
    table.insert(self._cards, 1, card)
end

function Pile:addCards(cards)
    for i,v in ipairs(cards) do
        self:addCard(v)
    end
end

function Pile:draw(i)
    i = i or 1
    local c = self._cards[i]
    table.remove(self._cards, i)
    return c
end

function Pile:shuffle()
    prox.table.shuffle(self._cards)
end

function Pile:clear()
    self._cards = {}
end

function Pile:size()
    return #self._cards
end

function Pile:getCards()
    return self._cards
end

return Pile

--- Card pile abstract datastructure
-- @classmod battle.Pile
local Pile = class("battle.Pile")

--- Constructor.
-- @param cards (optional) Table of @{core.Card} to add to pile
function Pile:initialize(cards)
    if cards then
        self._cards = prox.table.copy(cards)
    else
        self._cards = {}
    end
end

--- Add card to pile.
-- @param card @{core.Card} instance of card to add to top of pile.
function Pile:addCard(card)
    table.insert(self._cards, 1, card)
end

--- Add stack of cards to pile.
-- @param cards Table of @{core.Card} instances to add to top of pile. First card in stack will be added on top.
function Pile:addCards(cards)
    for i=#cards,1,-1 do
        self:addCard(cards[i])
    end
end

--- Draw a card from pile.
-- @param i (optional) Position in pile to draw. If not given, top card will be drawn.
function Pile:draw(i)
    i = i or 1
    local c = self._cards[i]
    table.remove(self._cards, i)
    return c
end

--- Shuffle pile.
function Pile:shuffle()
    prox.table.shuffle(self._cards)
end

--- Empty pile.
function Pile:clear()
    self._cards = {}
end

--- Get number of cards in pile.
function Pile:size()
    return #self._cards
end

--- Get table of cards in pile.
function Pile:getCards()
    return self._cards
end

return Pile

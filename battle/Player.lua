local Player = class("battle.Player")

function Player:initialize(deck)
    self.deck = prox.table.copy(deck)
    prox.table.shuffle(self.deck)

    self.hand = {}
    self.discard = {}
end

function Player:draw(n)
    for i = 1,n do
        if #self.deck == 0 then
            self:shuffle()
        end
        if #self.deck == 0 then
            break
        end
        table.insert(self.hand, self.deck[1])
        table.remove(self.deck, 1)
    end
end

function Player:discard(i)
    table.insert(self.discard, self.hand[i])
    table.remove(self.hand, i)
end

function Player:shuffle()
    self.deck = self.discard
    self.discard = {}
    prox.table.shuffle(self.deck)
end

return Player

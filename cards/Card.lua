local Card = class("cards.Card")

function Card:initialize(name, token, tag, buy, scrap, active, reactive, description)
    self.name = name
    self.token = token
    self.tag = tag
    self.buy = buy
    self.scrap = scrap
    self.active = active
    self.reactive = reactive
    self.description = description
end

return Card

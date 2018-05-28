--- Card description class.
-- @classmod cards.Card

local Card = class("cards.Card")

--- Constructor.
-- @param id (strings) Card ID
-- @param name (string) Name of the card
-- @param token (boolean) Is the card a token type
-- @param type (string) Card type
-- @param buy (number) Buy cost
-- @param scrap (number) Scrap cost
-- @param block (number) Block value (or nil)
-- @param active Active card effect tree
-- @param reactive Reactive card effect tree
-- @param text (string) Card effect description
-- @param description (string) Long card lore description
function Card:initialize(id, name, token, type, buy, scrap, block, active, reactive, text, description)
    self.id = id
    self.name = name
    self.token = token
    self.type = type
    self.buy = buy
    self.scrap = scrap
    self.block = block
    self.active = active
    self.reactive = reactive
    self.text = text
    self.description = description
end

--- Get card's unique ID
-- @return (string) Card ID
function Card:getID()
    return self.id
end

--- Check if card is a token.
-- @return True if card is a token, false otherwise
function Card:isToken()
    return self.token
end

--- Get card effect description text.
-- @return Card text
function Card:getText()
    return self.text
end

return Card

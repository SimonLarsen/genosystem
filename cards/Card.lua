--- Card description class.
-- @classmod cards.Card

local Card = class("cards.Card")

--- Constructor.
-- @param id (strings) Card ID
-- @param name (string) Name of the card
-- @param token (boolean) Is the card a token type
-- @param decoy (boolean) Is the card a decoy
-- @param tag (string) (optional) Card tag
-- @param buy (number) Buy cost
-- @param scrap (number) Scrap cost
-- @param active Active card effect tree
-- @param reactive Reactive card effect tree
-- @param text (string) Card effect description
-- @param description (string) Long card lore description
function Card:initialize(id, name, token, decoy, tag, buy, scrap, active, reactive, text, description)
    self.id = id
    self.name = name
    self.token = token
    self.decoy = decoy
    self.tag = tag
    self.buy = buy
    self.scrap = scrap
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

--- Check if card is a decoy.
-- @return True if card is a decoy, false otherwise
function Card:isDecoy()
    return self.decoy
end

return Card

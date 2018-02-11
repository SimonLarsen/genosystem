--- Card description class.
-- @classmod cards.Card

local Card = class("cards.Card")

--- Constructor.
-- @param id (strings) Card ID
-- @param name (string) Name of the card
-- @param token (boolean) If the card a token type
-- @param tag (string) (optional) Card tag
-- @param buy (number) Buy cost
-- @param scrap (number) Scrap cost
-- @param active Active card effect tree
-- @param reactive Reactive card effect tree
-- @param text (string) Card effect description
-- @param description (string) Long card lore description
function Card:initialize(id, name, token, tag, buy, scrap, active, reactive, text, description)
    self.id = id
    self.name = name
    self.token = token
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

--- Execute card's active effects.
-- @param variables Table of current battle variables
-- @param events (Output) Table to return events.
-- @return Table of events
function Card:play(variables, events)
    for i,v in ipairs(self.active) do
        v:apply(variables, events)
    end
    return events
end

--- Execute card's reactive effects.
-- @param variables Table of current battle variables
-- @param events (Output) Table to return events.
-- @return Table of events
function Card:react(variables, events)
    for i,v in ipairs(self.reactive) do
        v:apply(variables, events)
    end
    return events
end

return Card

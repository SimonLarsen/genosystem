--- Card description class.
-- @classmod cards.Card

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

--- Execute card's active effects.
-- @param variables Table of current battle variables
-- @param events (Output) Table to return events.
-- @return Table of events
function Card:play(variables, events)
    self.active:play(variables, events)
    return events
end

--- Execute card's reactive effects.
-- @param variables Table of current battle variables
-- @param events (Output) Table to return events.
-- @return Table of events
function Card:react(variables, events)
    self.reactive(variables, events)
    return events
end

--- Check if card is a token.
-- @return True if card is a token, false otherwise
function Card:isToken()
    return self.token
end

return Card

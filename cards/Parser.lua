--- Card effect description parser
-- @classmod cards.Parser

local Card = require("cards.Card")
local Action = require("cards.Action")
local Condition = require("cards.Condition")
local ConditionalAction = require("cards.ConditionalAction")

local Parser = class("cards.Parser")

local function parseEffects()
    local effects = {}

    for i, f in ipairs(love.filesystem.getDirectoryItems("cards/effects")) do
        if prox.string.endswith(f, ".lua") then
            local e = require("cards.effects." .. string.sub(f, 1, #f-4))
            assert(effects[e:getType()] == nil, "Effect type \"" .. e:getType() .. "\" already defined.")
            effects[e:getType()] = e
        end
    end

    return effects
end

local function tobool(x) return x == "true" end

local function totable(...) return {...} end

local function toobj(cl)
    return function(...) return cl(...) end
end

local function toeffect(effects)
    return function(id, ...) return effects[id](...) end
end

local function toboolean(s)
    s = string.lower(s)
    return s == "true" or s == "1" or s == "yes"
end

--- Constructor.
function Parser:initialize()
    self.grammar = self:buildGrammar()
end

--- Builds and returns the LPeg grammar.
-- @return LPeg parser for card effect descriptions
function Parser:buildGrammar()
    local lpeg = require("LuLPeg.lulpeg")
    lpeg.locale(lpeg)
    local P, V = lpeg.P, lpeg.V

    local effects = parseEffects()

    local OWS = lpeg.space^0
    local WS = lpeg.space^1
    local PAREN = function(x)
        return OWS * "(" *OWS* x *OWS* ")" * OWS
    end

    local comma = OWS * "," * OWS
    local bool = (P"true" + "false") / tobool
    local str = lpeg.alpha * lpeg.alnum^0 / tostring
    local number = lpeg.digit^1 / tonumber
    local arg = bool + number + str
    local target = (P"self" + "target" + "party" + "enemies") / tostring
    local op = (P">" + "<" + ">=" + "<=" + "==" + "!=") / tostring

    local effect = str * (WS * arg)^0 / toeffect(effects)

    local effect_list = effect / totable +
                        PAREN(effect * (comma * effect)^0) / totable

    local action = OWS * target *WS* effect_list * OWS / toobj(Action)
    local condition = OWS * str *WS* op *WS* arg * OWS / toobj(Condition)

    local body = lpeg.P{
        "body",
        statement = action +
                    P"if" * PAREN(condition) * PAREN(V"body") * ((OWS* "else" * PAREN(V"body"))^-1) / toobj(ConditionalAction),
        body = OWS * V"statement" * (comma * V"statement")^0 * OWS / totable
    }

    return body * -1
end

--- Parse a card effect description.
-- @param s (string) Card effect description.
-- @return Description as an @{cards.Action} tree
function Parser:parse(s)
    if prox.string.trim(s) == "" then
        return {}
    else
        local out = self.grammar:match(s)
        assert(out, "Malformed card effect description \"" .. s .. "\"")
        return out
    end
end

--- Parses cards from a CSV file database.
-- @param path (string) Path to CSV file
-- @return A table mapping card IDs to @{cards.Card} instances.
function Parser:readCards(path)
    local csv = require("lua-csv.lua.csv")

    local f = csv.open(path, {header=true})
    local cards = {}
    for e in f:lines() do
        local c = Card(
            e.id,
            e.name,
            toboolean(e.token),
            toboolean(e.decoy),
            e.tag,
            tonumber(e.buy),
            tonumber(e.scrap),
            self:parse(e.active),
            self:parse(e.reactive),
            e.text,
            e.description
        )
        cards[e.id] = c
    end
    return cards
end

return Parser

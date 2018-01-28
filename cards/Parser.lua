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

function Parser:initialize()
    self.grammar = self:buildGrammar()
end

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

function Parser:parse(s)
    if prox.string.trim(s) == "" then
        return {}
    else
        local out = self.grammar:match(s)
        assert(out, "Malformed card effect description \"" .. s .. "\"")
        return out
    end
end

local function toboolean(s)
    s = string.lower(s)
    return s == "true" or s == "1" or s == "yes"
end

function Parser:readCards(path)
    local csv = require("lua-csv.lua.csv")

    local f = csv.open(path, {header=true})
    local cards = {}
    for e in f:lines() do
        local c = Card(
            e.name,
            toboolean(e.token),
            e.tag,
            tonumber(e.buy),
            tonumber(e.scrap),
            self:parse(e.active),
            self:parse(e.reactive),
            self.description
        )
        table.insert(cards, c)
    end
    return cards
end

return Parser

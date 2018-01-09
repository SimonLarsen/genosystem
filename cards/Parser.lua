local Card = require("cards.Card")
local Action = require("cards.Action")

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

local function totable(...)
    return {...}
end

local function toobj(cl)
    return function(...) return cl(...) end
end

function Parser:initialize()
	local lpeg = require("LuLPeg.lulpeg")
	lpeg.locale(lpeg)

	local effects = parseEffects()

	local ows = lpeg.space^0
	local ws = lpeg.space^1

	local comma = ows * "," * ows
	local card = lpeg.alpha * lpeg.alnum^0 / tostring
	local pile = (lpeg.P("hand") + lpeg.P("deck") + lpeg.P("discard")) / tostring
	local count = lpeg.digit^1 / tonumber

	local target = (lpeg.P("self") + lpeg.P("target") + lpeg.P("party") + lpeg.P("enemies")) / tostring

	local effect = lpeg.P("hit") * ws * count / toobj(effects.hit) +
				   lpeg.P("draw") * ws * count / toobj(effects.draw) +
				   lpeg.P("deal") * ws * count * ws * card * ws * "to" * ws * pile / toobj(effects.deal)

	local effect_list = effect / totable +
						lpeg.P("(") * ows * effect * (comma * effect)^0 * ows * ")" / totable

	local action = target * ws * effect_list / toobj(Action)

	local body = ows * action * (comma * action)^0 * ows / totable

	self.grammar = body * -1
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

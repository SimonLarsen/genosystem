class = require("prox.middleclass.middleclass")

local lpeg = require("LuLPeg.lulpeg")
lpeg.locale(lpeg)

local Action = require("cards.Action")

effects = {
    hit = require("cards.effects.Hit"),
    draw = require("cards.effects.Draw"),
    deal = require("cards.effects.Deal")
}

function totable(...)
    return {...}
end

function toobj(cl)
    return function(...) return cl(...) end
end

local ows = lpeg.S(" \t")^0
local ws = lpeg.S(" \t")^1

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

local desc = ows * action * (comma * action)^0 * ows / totable

return desc * -1

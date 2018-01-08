lpeg = require("LuLPeg.lulpeg")
lpeg.locale(lpeg)

function totable(...)
	return {...}
end

ows = lpeg.S(" \t")^0
ws = lpeg.S(" \t")^1

comma = ows * "," * ows

card = lpeg.alpha * lpeg.alnum^0 / tostring

pile = (lpeg.P("hand") + lpeg.P("deck") + lpeg.P("discard")) / tostring

count = lpeg.digit^1 / tonumber

target = (lpeg.P("self") + lpeg.P("target") + lpeg.P("party") + lpeg.P("enemies")) / tostring

function effect_hit(count)
	return {type="hit", count=count}
end

function effect_draw(count)
	return {type="draw", count=count}
end

function effect_deal(count, card, pile)
	return {type="deal", count=count, card=card, pile=pile}
end

function action_obj(target, effects)
	return {target=target, effects=effects}
end

effect = lpeg.P("hit") * ws * count / effect_hit +
         lpeg.P("draw") * ws * count / effect_draw +
		 lpeg.P("deal") * ws * count * ws * card * ws * "to" * ws * pile / effect_deal

effect_list = effect / totable +
              lpeg.P("(") * ows * effect * (comma * effect)^0 * ows * ")" / totable

action = target * ws * effect_list / action_obj

desc = ows * action * (comma * action)^0 * ows

parser = desc * -1

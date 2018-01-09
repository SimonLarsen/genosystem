prox = require("prox")
require("luafun.fun")()

local lovebird = require("lovebird")

local Parser = require("cards.Parser")

function prox.load()
	prox.window.set(640, 360, true, 2, false, "scale")
	local parser = Parser()
	cards = parser:readCards("data/cards.csv")
end

function prox.update(dt)
	lovebird.update()
end

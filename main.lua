prox = require("prox")
require("luafun.fun")()

local Parser = require("cards.Parser")
AssetManager = require("core.AssetManager")

local function readDeckFile(path, card_index)
    local deck = {}
    for line in love.filesystem.lines(path) do
        local parts = prox.string.split(line, " ")
        local id = parts[1]
        assert(card_index[id], "Invalid card id: " .. id)
        local count = tonumber(parts[2])
        for i=1,count do
            table.insert(deck, card_index[id])
        end
    end
    return deck
end

function prox.load()
    prox.window.set(640, 360, true, 2, false, "scale")

    prox.gui.theme.color = {
        normal  = {bg = { 66, 66, 66}, fg = {255,255,255}},
        hovered = {bg = { 50,153,187}, fg = {255,255,255}},
        active  = {bg = {255,153,  0}, fg = {225,225,225}}
    }
    prox.gui.theme.cornerRadius = 3

    local parser = Parser()
    local card_index = parser:readCards("data/cards.csv")
    local deck = readDeckFile("data/decks/test1.txt", card_index)

    local names = {
        {"Anders","Preben","Thomas"},
        {"Magle 1","Magle 2","Magle 3"}
    }

    prox.engine:addSystem(require("systems.logic.BattleSystem")())
    prox.engine:addSystem(require("systems.logic.CardSystem")())
    prox.engine:addSystem(require("systems.logic.HandSystem")())
    prox.engine:addSystem(require("systems.graphics.IndicatorSystem")())

    local party = {}
    for i=1,2 do
        party[i] = {}
        for j=1,3 do
            local p = require("components.battle.Player")(names[i][j], deck)
            table.insert(party[i], p)
        end
    end

    local hand = Entity()
    hand:add(require("components.battle.Hand")())
    hand:add(prox.Transform(prox.window.getWidth()/2., prox.window.getHeight()-60))
    local battle = Entity()
    battle:add(require("components.battle.Battle")(party[1], party[2], card_index, hand))

    prox.engine:addEntity(battle)
    prox.engine:addEntity(hand)
end

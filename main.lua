prox = require("prox")
require("luafun.fun")()

local lovebird = require("lovebird")
local Parser = require("cards.Parser")

local engine

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

    local parser = Parser()
    local card_index = parser:readCards("data/cards.csv")
    local deck = readDeckFile("data/decks/test1.txt", card_index)

    engine = Engine()

    local names = {
        {"Anders","Preben","Thomas"},
        {"Magle 1","Magle 2","Magle 3"}
    }

    local party = {}
    for i=1,2 do
        party[i] = {}
        for j=1,3 do
            local p = require("components.battle.Player")(names[i][j], deck)
            table.insert(party[i], p)
        end
    end

    local battle = Entity()
    battle:initialize()
    battle:add(require("components.battle.Battle")(party[1], party[2], card_index))

    engine:addEntity(battle)

    local battle_system = require("systems.logic.BattleSystem")()
    engine:addSystem(battle_system)
end

function prox.update(dt)
    lovebird.update()
    engine:update(dt)
end

function prox.draw()
    engine:draw()
end

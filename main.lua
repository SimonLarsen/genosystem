prox = require("prox")
require("luafun.fun")()

local lovebird = require("lovebird")

local Parser = require("cards.Parser")
local Player = require("battle.Player")

local function readDeckFile(path, cards)
    local deck = {}
    for line in love.filesystem.lines(path) do
        local parts = prox.string.split(line, " ")
        local id = parts[1]
        local count = tonumber(parts[2])
        for i=1,count do
            table.insert(deck, cards[id])
        end
    end
    return deck
end

function prox.load()
    prox.window.set(640, 360, true, 2, false, "scale")
    local parser = Parser()
    local cards = parser:readCards("data/cards.csv")
    local deck = {}
    for i=1,20 do
        table.insert(deck, cards["strike1"])
    end

    local deck = readDeckFile("data/decks/test1.txt", cards)
    local player = Player(deck)

    local events = {}
    player:playCard(1, cards, {}, events)
    for i,v in ipairs(events) do
        print(v)
    end
end

function prox.update(dt)
    lovebird.update()
end

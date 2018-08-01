prox = require("prox")
require("luafun.fun")()

local Parser = require("cards.Parser")
AssetManager = require("core.AssetManager")

local function readDeckFile(path, card_index)
    local csv = require("lua-csv.lua.csv")
    local data = love.filesystem.read(path)
    local f = csv.openstring(data, {header=true})
    local deck = {}
    for e in f:lines() do
        assert(card_index[e.id], "Invalid card id: " .. e.id)
        local count = tonumber(e.count)
        for i=1,count do
            table.insert(deck, card_index[e.id])
        end
    end
    return deck
end

function prox.load()
    prox.window.set(640, 360, true, 2, false, "scale")

    prox.gui.theme.color = {
        normal  = {bg = {0.25,0.25,0.25}, fg = {1,1,1}},
        hovered = {bg = {0.20,0.60,0.73}, fg = {1,1,1}},
        active  = {bg = {1.00,0.60,0.00}, fg = {1,1,1}}
    }
    prox.gui.theme.cornerRadius = 3

    local parser = Parser()
    local card_index = parser:readCards("data/cards.csv")
    local deck = readDeckFile("data/decks/test1.csv", card_index)

    prox.engine:addSystem(require("systems.battle.BattleSystem")())
    prox.engine:addSystem(require("systems.battle.CardSystem")())
    prox.engine:addSystem(require("systems.battle.HandSystem")())
    prox.engine:addSystem(require("systems.battle.IndicatorSystem")())

    local bls = require("systems.battle.BattleLogSystem")()
    prox.engine:addSystem(bls, "update")
    prox.engine:addSystem(bls, "draw")

    local player = require("components.battle.Player")(1, "Anders", deck)
    local enemy = require("components.battle.Player")(2, "Preben", deck, require("ai.RandomAI")())

    local cam = Entity()
    cam:add(prox.Transform(prox.window.getWidth()/2, prox.window.getHeight()/2))
    cam:add(prox.Camera(true))
    prox.engine:addEntity(cam)

    local player_hand = Entity()
    player_hand:add(require("components.battle.Hand")(1))
    player_hand:add(prox.Transform(prox.window.getWidth()/2, prox.window.getHeight()-55))
    prox.engine:addEntity(player_hand)

    local enemy_hand = Entity()
    enemy_hand:add(require("components.battle.Hand")(2))
    enemy_hand:add(prox.Transform(prox.window.getWidth()/2, 55))
    prox.engine:addEntity(enemy_hand)

    local battle = Entity()
    battle:add(require("components.battle.Battle")(
        player, enemy,
        player_hand:get("components.battle.Hand"),
        enemy_hand:get("components.battle.Hand"),
        card_index
    ))
    prox.engine:addEntity(battle)

    local battle_log = Entity()
    battle_log:add(require("components.battle.BattleLog")(card_index))
    prox.engine:addEntity(battle_log)
end

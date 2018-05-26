--- In-battle controller system.
-- @classmod systems.logic.BattleSystem
local BattleSystem = class("systems.logic.BattleSystem", System)

local Battle = require("components.battle.Battle")
local Card = require("components.battle.Card")
local Indicator = require("components.battle.Indicator")

local TargetEffect = require("cards.TargetEffect")
local CardEffect = require("cards.CardEffect")

local SelectTargetEvent = require("events.SelectTargetEvent")
local MAX_ACTIONS = 3
local HAND_SIZE = 5

local function make_card_entity(battle, player, card, x, y, z)
    local e = Entity()
    e:add(prox.Transform(x, y, z))
    e:add(prox.Animator(AssetManager.getCardAnimator(card.id)))
    local cc = Card(card)
    cc.dir = 0 --1
    cc.target_dir = 0 --1
    if player.id == 1 then
        cc.target_dir = 0
    end
    e:add(cc)
    prox.engine:addEntity(e)
    return e
end

local function make_indicator_entity(battle, player, type, value)
    local e = Entity()
    e:add(prox.Tween())

    local x, y
    x = prox.window.getWidth()-32
    if player.id == 1 then y = prox.window.getHeight()-32 else y = 32 end
    local targetx, targety = x, y-5
    e:add(prox.Transform(x, y))
    e:add(Indicator(type, 1.0, value))
    e:get("Tween"):add(0.5, e:get("Transform"), {x=targetx, y=targety}, "outQuad")
    e:get("Tween"):add(1.0, e:get("components.battle.Indicator"), {alpha=0},
        function(t,b,c,d) return prox.tween.easing.linear(t*2-d,b,c,d)
    end)
    prox.engine:addEntity(e)
    return e
end

function BattleSystem:initialize()
    System.initialize(self)

    prox.events:addListener("events.PlayCardEvent", self, self.onPlayCard)
    prox.events:addListener("events.SelectTargetEvent", self, self.onSelectTarget)
end

function BattleSystem:requires()
    return {"components.battle.Battle"}
end

function BattleSystem:update(dt)
    local text_font = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 10)
    local title_font = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 13)

    prox.resources.setFont(text_font)

    for _, e in pairs(self.targets) do
        local battle = e:get("components.battle.Battle")

        if battle.state == Battle.static.STATE_INIT then
            for _, player in ipairs(battle.players) do
                self:effectDrawCards(battle, player, HAND_SIZE)
            end
            battle.state = Battle.static.STATE_PREPARE

        elseif battle.state == Battle.static.STATE_PREPARE then
            self:effectDrawCards(battle, battle:currentPlayer(), HAND_SIZE-#battle:currentPlayer().hand)
            battle.state = Battle.static.STATE_PLAY_CARD
            battle.actions = MAX_ACTIONS

        elseif battle.state == Battle.static.STATE_PLAY_CARD then
            if prox.gui.Button("End turn", {font=title_font}, 10, prox.window.getHeight()-30, 70, 24).hit then
                battle.current_player = battle.current_player % 2 + 1
                battle.state = Battle.static.STATE_PREPARE
            end

        elseif battle.state == Battle.static.STATE_REACT then
            if prox.gui.Button("Don't block", {font=title_font}, 10, prox.window.getHeight()-60).hit then
                battle.state = Battle.static.STATE_REACT_DAMAGE
            end
            prox.gui.Label("Damage: " .. battle.damage, {font=title_font, align="right"}, prox.window.getWidth()-216, prox.window.getHeight()/2-32, 200, 64)

        elseif battle.state == Battle.static.STATE_REACT_DAMAGE then
            self:hitPlayer(battle, battle:opponentPlayer(), battle.damage)
            battle.state = Battle.static.STATE_RESOLVE

        elseif battle.state == Battle.static.STATE_RESOLVE then
            if prox.engine:getEntityCount("components.battle.Indicator") == 0 then
                if #battle.effects > 0 then
                    self:resolve(battle)
                else
                    battle.state = Battle.static.STATE_PLAY_CARD
                end
            end

        elseif battle.state == Battle.static.STATE_REACT_RESOLVE then
            if prox.engine:getEntityCount("components.battle.Indicator") == 0 then
                if #battle.react_effects > 0 then
                    self:resolve(battle)
                else
                    battle.state = Battle.static.STATE_REACT_DAMAGE
                end
            end
        end

        if battle.current_player == 1 then
            prox.gui.Label("→→→", {font=title_font}, 128, prox.window.getHeight()-71, 64, 32)
        else
            prox.gui.Label("→→→", {font=title_font}, 128, 39, 64, 32)
        end

        prox.gui.Label("Actions: " .. battle.actions, {font=title_font, align="left"}, 16, prox.window.getHeight()/2-32, 200, 64)

        prox.gui.Label(
            string.format("Deck: %d\nDiscard: %d\nWounded: %d", #battle.players[1].deck, #battle.players[1].discard, #battle.players[1].wounded),
            {font=title_font, align="right"}, prox.window.getWidth()-105, prox.window.getHeight()-65, 100, 60
        )
        prox.gui.Label(
            string.format("Deck: %d\nDiscard: %d\nWounded: %d", #battle.players[2].deck, #battle.players[2].discard, #battle.players[2].wounded),
            {font=title_font, align="right"}, prox.window.getWidth()-105, 5, 100, 60
        )
    end
end

function BattleSystem:onPlayCard(event)
    for _, e in pairs(self.targets) do
        local battle = e:get("components.battle.Battle")
        if battle.state == Battle.static.STATE_PLAY_CARD
        and battle.actions > 0
        and event.player == battle.current_player then
            local player = battle.players[event.player]
            assert(event.card >= 1 and event.card <= #player.hand, "Invalid hand card index.")
            local card = player.hand[event.card]
            local hand = battle.hands[event.player]

            local variables = {}
            self:playCard(battle, card, {})

            table.remove(player.hand, event.card)
            if not card:isToken() then
                table.insert(player.discard, 1, card)
            end
            prox.engine:removeEntity(hand.cards[event.card])
            table.remove(hand.cards, event.card)

            battle.state = Battle.static.STATE_RESOLVE
            battle.actions = battle.actions - 1

        elseif battle.state == Battle.static.STATE_REACT
        and event.player ~= battle.current_player then
            local player = battle.players[event.player]
            assert(event.card >= 1 and event.card <= #player.hand, "Invalid hand card index.")
            local card = player.hand[event.card]
            local hand = battle.hands[event.player]

            if card.block == nil then
                print("Card cannot block.")
                return
            end

            battle.damage = math.max(battle.damage - card.block, 0)

            local variables = {}
            self:reactCard(battle, card, {})
            
            table.remove(player.hand, event.card)
            if not card:isToken() then
                table.insert(player.discard, 1, card)
            end
            prox.engine:removeEntity(hand.cards[event.card])
            table.remove(hand.cards, event.card)

            battle.state = Battle.static.STATE_REACT_RESOLVE
        end
    end
end

function BattleSystem:onSelectTarget(event)
    for _, e in pairs(self.targets) do
        local battle = e:get("components.battle.Battle")
        battle.target = battle.party[event.party][event.player]
        battle.state = Battle.static.STATE_RESOLVE
    end
end

--- Execute card's active effects.
-- @param card @{cards.Card} instance to play.
-- @param variables Table of current battle variables.
-- @param effects (Output) Table to return effects.
-- @return Table of effects
function BattleSystem:playCard(battle, card, variables)
    battle.effects = {}
    for _, v in ipairs(card.active) do
        v:apply(variables, battle.effects)
    end
end

--- Execute card's reactive effects.
-- @param card @{cards.Card} instance to play.
-- @param variables Table of current battle variables.
-- @param effects (Output) Table to return effects.
-- @return Table of effects
function BattleSystem:reactCard(battle, card, variables)
    battle.react_effects = {}
    for _, v in ipairs(card.reactive) do
        v:apply(variables, battle.react_effects)
    end
end

--- Get card effect target matching target string.
-- @param battle Current @{components.battle.Battle} instance.
-- @param target Target string.
-- @return A @{components.battle.Player} instance.
function BattleSystem:getTarget(battle, target)
    if battle.state == Battle.static.STATE_RESOLVE then
        if target == "self" then
            return battle:currentPlayer()
        elseif target == "enemy" then
            return battle:opponentPlayer()
        end
    elseif battle.state == Battle.static.STATE_REACT_RESOLVE then
        if target == "self" then
            return battle:opponentPlayer()
        elseif target == "enemy" then
            return battle:currentPlayer()
        end
    end
    error(string.format("Invalid card effect target."))
end

function BattleSystem:resolve(battle)
    local e
    if battle.state == Battle.static.STATE_RESOLVE then
        e = battle.effects[1]
        table.remove(battle.effects, 1)
    elseif battle.state == Battle.static.STATE_REACT_RESOLVE then
        e = battle.react_effects[1]
        table.remove(battle.react_effects, 1)
    else
        error("Can only resolve in STATE_RESOLVE or STATE_REACT_RESOLVE state.")
    end
    assert(e:isInstanceOf(CardEffect), "Card effect is not of class CardEffect")

    local target = self:getTarget(battle, e.target)
    local effect = e.effect

    local type = effect.type
    if type == "deal" then
        self:effectDealCards(battle, target, effect.card, effect.pile, effect.count)
    elseif type == "draw" then
        self:effectDrawCards(battle, target, effect.count)
    elseif type == "discard" then
        self:effectDiscardCards(battle, target, effect.count)
    elseif type == "hit" then
        if battle.state == Battle.static.STATE_RESOLVE
        and e.target == "enemy" and self:playerCanBlock(target) then
            battle.damage = effect.count
            battle.state = Battle.static.STATE_REACT
        else
            self:hitPlayer(battle, target, effect.count)
        end
    elseif type == "replace" then
        self:effectReplaceCards(battle, target, effect.card, effect.count)
    elseif type == "restore" then
        self:effectRestoreCards(battle, target, effect.count)
    elseif type == "gainaction" then
        self:effectGainActions(battle, effect.count)
    else
        error(string.format("Unknown card effect type: \"%s\"", type))
    end
end

function BattleSystem:effectDrawCards(battle, player, count)
    if count <= 0 then return end

    for i=1, count do
        local card = player:draw()
        if card == nil then
            break
        end
        local e = make_card_entity(battle, player, card, prox.window.getWidth()/2, prox.window.getHeight()/2, i)
        local hand = battle.hands[player.id]
        table.insert(hand.cards, e)
        table.insert(player.hand, card)
    end

    make_indicator_entity(battle, player, Indicator.static.TYPE_DRAW, count)
end

function BattleSystem:effectDiscardCards(battle, player, count)
    if count <= 0 then return end
    count = math.min(count, #player.hand)
    local hand = battle.hands[player.id]
    for i=1, count do
        local index = love.math.random(#player.hand)
        player:discardCard(index)
        prox.engine:removeEntity(hand.cards[index])
        table.remove(hand.cards, index)
    end

    make_indicator_entity(battle, player, Indicator.static.TYPE_DISCARD, count)
end

function BattleSystem:effectDealCards(battle, player, card_id, pile, count)
    local card = battle.card_index[card_id]
    for i=1, count do
        if pile == "hand" then
            table.insert(player.hand, card)
            local e = make_card_entity(battle, player, card, prox.window.getWidth()/2, prox.window.getHeight()/2)
            local hand = battle.hands[player.id]
            table.insert(hand.cards, e)
        elseif pile == "deck" then
            table.insert(player.deck, 1, card)
        elseif pile == "discard" then
            table.insert(player.discard, 1, card)
        else
            error(string.format("Unknown card pile target: \"%s\"", pile))
        end
    end

    make_indicator_entity(battle, player, Indicator.static.TYPE_DEAL, count)
end

function BattleSystem:effectReplaceCards(battle, player, card_id, count)
    local card = battle.card_index[card_id]
    local hand = battle.hands[player.id]

    count = math.min(count, #player.hand)
    for i=1, count do
        local index = love.math.random(#player.hand)
        player:discardCard(index)
        prox.engine:removeEntity(hand.cards[index])
        table.remove(hand.cards, index)
    end

    self:effectDealCards(battle, player, card_id, "hand", count)
end

function BattleSystem:effectRestoreCards(battle, player, count)
    count = math.min(count, #player.wounded)
    for i=1, count do
        local card = player.wounded[1]
        table.remove(player.wounded, 1)
        table.insert(player.discard, 1, card)
    end

    make_indicator_entity(battle, player, Indicator.static.TYPE_RESTORE, count)
end

function BattleSystem:effectGainActions(battle, count)
    battle.actions = battle.actions + count
    make_indicator_entity(battle, battle:currentPlayer(), Indicator.static.TYPE_GAIN_ACTION, count)
end

function BattleSystem:hitPlayer(battle, player, damage)
    local hand = battle.hands[player.id]
    local hits = player:hit(damage)
    make_indicator_entity(battle, player, Indicator.static.TYPE_DAMAGE, damage)
end

function BattleSystem:playerCanBlock(player)
    for _, card in ipairs(player.hand) do
        if card.block ~= nil then
            return true
        end
    end
    return false
end

return BattleSystem

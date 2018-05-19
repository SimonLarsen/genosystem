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

local function make_indicator_entity(battle, player, type, value, token)
    local e = Entity()
    e:add(prox.Tween())

    local x, y
    x = prox.window.getWidth()-32
    if player.id == 1 then y = prox.window.getHeight()-32 else y = 32 end
    local targetx, targety = x, y-5
    e:add(prox.Transform(x, y))
    e:add(Indicator(type, 1.5, value))
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
                self:drawCards(battle, player, HAND_SIZE)
            end
            battle.state = Battle.static.STATE_PREPARE

        elseif battle.state == Battle.static.STATE_PREPARE then
            self:drawCards(battle, battle:currentPlayer(), HAND_SIZE-#battle:currentPlayer().hand)
            battle.state = Battle.static.STATE_PLAY_CARD
            battle.actions = MAX_ACTIONS

        elseif battle.state == Battle.static.STATE_PLAY_CARD then
            if prox.gui.Button("End turn", {font=title_font}, 10, prox.window.getHeight()-30, 70, 24).hit then
                self:endTurn(battle)
            end

        elseif battle.state == Battle.static.STATE_RESOLVE then
            if #battle.effects > 0 then
                self:resolve(battle)
            else
                local hand = battle:currentHand()
                prox.engine:removeEntity(hand.active)
                hand.active = nil
                battle.state = Battle.static.STATE_PLAY_CARD
            end
        end

        prox.gui.Label(
            string.format("Deck: %d\nDiscard: %d\nWounded: %d", #battle.players[1].deck, #battle.players[1].discard, #battle.players[1].wounded),
            {font=title_font, align="right"}, prox.window.getWidth()-85, prox.window.getHeight()-65, 80, 60
        )
        prox.gui.Label(
            string.format("Deck: %d\nDiscard: %d\nWounded: %d", #battle.players[2].deck, #battle.players[2].discard, #battle.players[2].wounded),
            {font=title_font, align="right"}, prox.window.getWidth()-85, 5, 80, 60
        )
    end
end

function BattleSystem:onPlayCard(event)
    for _, e in pairs(self.targets) do
        local battle = e:get("components.battle.Battle")
        if battle.state == Battle.static.STATE_PLAY_CARD and event.player == battle.current_player then
            local player = battle.players[event.player]
            assert(event.card >= 1 and event.card <= #player.hand, "Invalid hand card index.")

            battle.effects = {}
            local variables = {}
            local card = player.hand[event.card]
            table.remove(player.hand, event.card)
            self:playCard(card, {}, battle.effects)

            if not card:isToken() then
                table.insert(player.discard, 1, card)
            end

            local hand = battle:currentHand()
            local hc = hand.cards[event.card]
            table.remove(hand.cards, event.card)
            hand.active = hc
            battle.state = Battle.static.STATE_RESOLVE
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
function BattleSystem:playCard(card, variables, effects)
    for _, v in ipairs(card.active) do
        v:apply(variables, effects)
    end
    return effects
end

--- Execute card's reactive effects.
-- @param card @{cards.Card} instance to play.
-- @param variables Table of current battle variables.
-- @param effects (Output) Table to return effects.
-- @return Table of effects
function BattleSystem:reactCard(card, variables, effects)
    for _, v in ipairs(card.reactive) do
        v:apply(variables, effects)
    end
    return effects
end

--- Get list of player targets matching target string.
-- @param battle Current @{components.battle.Battle} instance.
-- @param target Target string.
-- @return Table of @{components.battle.Player} instances.
function BattleSystem:getTargets(battle, target)
    if target == "self" then
        return {battle.players[battle.current_player]}
    elseif target == "enemy" then
        return {battle.players[battle.current_player % 2 + 1]}
    else
        error(string.format("Unknown target \"%s\"", target))
    end
end

function BattleSystem:resolve(battle)
    local e = battle.effects[1]
    table.remove(battle.effects, 1)

    if e:isInstanceOf(TargetEffect) then
        battle.state = Battle.static.STATE_TARGET

    elseif e:isInstanceOf(CardEffect) then
        local targets = self:getTargets(battle, e.target)
        local effect = e.effect

        local type = effect.type
        if type == "deal" then
            for _, target in ipairs(targets) do
                self:dealCards(battle, target, effect.card, effect.pile, effect.count)
            end
        elseif type == "draw" then
            for _, target in ipairs(targets) do
                self:drawCards(battle, target, effect.count)
            end
        elseif type == "hit" then
            for _, target in ipairs(targets) do
                self:hitPlayer(battle, target, effect.count)
            end
        elseif type == "replace" then
            for _, target in ipairs(targets) do
                self:replaceCards(battle, target, effect.card, effect.count)
            end
        elseif type == "restore" then
            for _, target in ipairs(targets) do
                self:restoreCards(battle, target, effect.count)
            end
        elseif type == "actions" then
            self:gainActions(battle, effect.count)
        end
    else
        error(string.format("Unknown card effect type: \"%s\"", e))
    end
end

function BattleSystem:getEffectText(battle)
    local target_effects = {}
    for _, v in ipairs(battle.effects) do
        if v:isInstanceOf(CardEffect) and v.target == "target" then
            table.insert(target_effects, v.effect)
        else
            break
        end
    end

    local effect_text = ""
    for i, v in ipairs(target_effects) do
        effect_text = effect_text .. v:getText() .. "."
        if i < #target_effects then
            effect_text = effect_text .. " "
        end
    end
    return effect_text
end

function BattleSystem:endTurn(battle)
    battle.current_player = battle.current_player % 2 + 1
    battle.state = Battle.static.STATE_PREPARE
end

function BattleSystem:drawCards(battle, player, count)
    if count <= 0 then
        return
    end

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

function BattleSystem:dealCards(battle, player, card_id, pile, count)
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
end

function BattleSystem:replaceCards(battle, player, card_id, count)
    local card = battle.card_index[card_id]
    local hand = battle.hands[player.id]

    count = math.min(count, #player.hand)
    for i=1, count do
        local index = love.math.random(#player.hand)
        player:discardCard(index)
        prox.engine:removeEntity(hand.cards[index])
        table.remove(hand.cards, index)
    end

    self:dealCards(battle, player, card_id, "hand", count)
end

function BattleSystem:restoreCards(battle, player, count)
    count = math.min(count, #player.wounded)
    for i=1, count do
        local card = player.wounded[1]
        table.remove(player.wounded, 1)
        table.insert(player.discard, 1, card)
    end

    make_indicator_entity(battle, player, Indicator.static.TYPE_RESTORE, count)
end

function BattleSystem:gainActions(battle, count)
    battle.actions = battle.actions + count
    make_indicator_entity(battle, battle:currentPlayer(), Indicator.static.TYPE_GAIN_ACTIONS, count)
end

function BattleSystem:hitPlayer(battle, player, damage)
    local hand = battle.hands[player.id]
    local hits = player:hit(damage)
    make_indicator_entity(battle, player, Indicator.static.TYPE_DAMAGE, damage)
end

return BattleSystem

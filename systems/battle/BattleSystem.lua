--- In-battle controller system.
-- @classmod systems.battle.BattleSystem
local BattleSystem = class("systems.battle.BattleSystem", System)

local Battle = require("components.battle.Battle")
local Card = require("components.battle.Card")
local Hand = require("components.battle.Hand")
local Indicator = require("components.battle.Indicator")

local Effect = require("battle.Effect")
local DrawEffect = require("cards.effects.draw")

local SelectTargetEvent = require("events.SelectTargetEvent")
local PlayCardEvent = require("events.PlayCardEvent")
local BattleLogEvent = require("events.BattleLogEvent")

local MAX_ACTIONS = 3
local HAND_SIZE = 5

function BattleSystem:initialize()
    System.initialize(self)

    prox.events:addListener("events.PlayCardEvent", self, self.onPlayCard)
end

function BattleSystem:requires()
    return {"components.battle.Battle"}
end

function BattleSystem:update(dt)
    local font_text = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 10)
    local font_title = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 13)
    local font_huge = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 32)

    local img_portrait = prox.resources.getImage("data/images/portrait.png")
    local img_icon_deck = prox.resources.getImage("data/images/icons/deck.png")
    local img_icon_discard = prox.resources.getImage("data/images/icons/discard.png")
    local img_icon_wounded = prox.resources.getImage("data/images/icons/wounded.png")

    prox.resources.setFont(font_text)

    local _, e = next(self.targets)
    local battle = e:get("components.battle.Battle")

    if battle.wait > 0 then
        battle.wait = battle.wait - dt

    elseif #battle.effects > 0 then
        self:resolve(battle)
        self:wait(battle, 0.8)

    elseif battle.state == Battle.static.STATE_INIT then
        for _, player in ipairs(battle.players) do
            self:effectDrawCards(battle, player, HAND_SIZE, true)
        end
        battle.state = Battle.static.STATE_PREPARE

    elseif battle.state == Battle.static.STATE_PREPARE then
        table.insert(battle.effects, Effect("self", false, DrawEffect(HAND_SIZE-#battle:currentPlayer().hand)))
        battle.state = Battle.static.STATE_PLAY
        battle.actions = MAX_ACTIONS

        for i, hand in ipairs(battle.hands) do
            if i == battle.current_player then
                hand.state = Hand.static.STATE_ACTIVE
            else
                hand.state = Hand.static.STATE_INACTIVE
            end
        end

    elseif battle.state == Battle.static.STATE_PLAY then
        if battle:currentPlayer():isAI() then
            if battle.actions == 0 then
                self:endTurn(battle)
            else
                local decision = battle:currentPlayer().ai:play(battle:currentPlayer(), battle:opponentPlayer())
                self:onPlayCard(PlayCardEvent(battle.current_player, decision))
            end
        else
            if prox.gui.Button("End turn", {font=font_title}, prox.window.getWidth()-110, prox.window.getHeight()/2-40, 100, 80).hit then
                self:endTurn(battle)
            end
        end

    elseif battle.state == Battle.static.STATE_REACT then
        if battle:opponentPlayer():isAI() then
            local decision = battle:opponentPlayer().ai:react(battle:opponentPlayer(), battle:currentPlayer(), battle.damage)
            if decision then
                self:onPlayCard(PlayCardEvent(battle.current_player % 2 + 1, decision))
            else
                self:endReact(battle)
            end
        else
            if prox.gui.Button("Don't react", {font=font_title}, prox.window.getWidth()-110, prox.window.getHeight()/2-40, 100, 80).hit then
                self:endReact(battle)
            end
        end
        prox.gui.Label("Damage: " .. battle.damage, {font=font_title, align="right"}, prox.window.getWidth()-216, prox.window.getHeight()/2-32)

    elseif battle.state == Battle.static.STATE_REACT_DAMAGE then
        self:hitPlayer(battle, battle:opponentPlayer(), battle.damage)
        battle.state = Battle.static.STATE_PLAY
    end

    prox.gui.Label(prox.string.trim(string.rep("Ø\n", battle.actions)), {font=font_title, align="center"}, prox.window.getWidth()-124, prox.window.getHeight()/2-50, 16, 100)

    -- portraits
    prox.gui.Image(img_portrait, prox.window.getWidth()-92, prox.window.getHeight()-92)
    prox.gui.Image(img_portrait, 18, 18)

    -- pile size icons
    prox.gui.Image(img_icon_deck, prox.window.getWidth()-150, prox.window.getHeight()-92)
    prox.gui.Image(img_icon_discard, prox.window.getWidth()-150, prox.window.getHeight()-64)
    prox.gui.Image(img_icon_wounded, prox.window.getWidth()-153, prox.window.getHeight()-37)

    prox.gui.Image(img_icon_deck, 114, 16)
    prox.gui.Image(img_icon_discard, 114, 45)
    prox.gui.Image(img_icon_wounded, 111, 72)

    -- pile size numbers
    prox.gui.Label(tostring(#battle.players[1].deck),    {font=font_title, align="left"}, prox.window.getWidth()-128, prox.window.getHeight()-91, 100, 16)
    prox.gui.Label(tostring(#battle.players[1].discard), {font=font_title, align="left"}, prox.window.getWidth()-128, prox.window.getHeight()-63, 100, 16)
    prox.gui.Label(tostring(#battle.players[1].wounded), {font=font_title, align="left"}, prox.window.getWidth()-128, prox.window.getHeight()-35, 100, 16)

    prox.gui.Label(tostring(#battle.players[2].deck),    {font=font_title, align="left"}, 135, 18, 100, 16)
    prox.gui.Label(tostring(#battle.players[2].discard), {font=font_title, align="left"}, 135, 46, 100, 16)
    prox.gui.Label(tostring(#battle.players[2].wounded), {font=font_title, align="left"}, 135, 74, 100, 16)
end

function BattleSystem:onPlayCard(event)
    local _, e = next(self.targets)
    local battle = e:get("components.battle.Battle")
    if battle.state == Battle.static.STATE_PLAY
    and event.player == battle.current_player
    and battle.actions > 0 and #battle.effects == 0 then
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

        local e = hand.cards[event.card]
        table.remove(hand.cards, event.card)

        e:get("Transform").z = 0
        e:get("Tween"):add(0.5, e:get("Transform"), {x=prox.window.getWidth()/2, y=prox.window.getHeight()/2}, "inOutQuad")
        e:get("Tween"):add(0.5, e:get("components.battle.Card"), {zoom=1.3}, "outQuad")
        e:get("Tween"):add(0.2, e:get("components.battle.Card"), {zoom=1.0}, "outQuad", 0.5)
        e:get("Tween"):add(0.4, e:get("components.battle.Card"), {dir=2}, "outQuad", 0.2)
        e:add(prox.RemoveAfterTime(0.8))

        local e_flash = Entity()
        e_flash:add(prox.Transform(prox.window.getWidth()/2, prox.window.getHeight()/2, -1))
        e_flash:add(prox.Tween())
        e_flash:add(prox.Sprite({image="data/images/card_flash.png", color={1,1,1,0}}))
        e_flash:get("Tween"):add(0.05, e_flash:get("Sprite"), {color={1,1,1,1}}, "inQuad", 0.75)
        e_flash:get("Tween"):add(0.30, e_flash:get("Sprite"), {color={1,1,1,0}, sx=1.4, sy=1.4}, "outQuad", 0.80)
        e_flash:add(prox.RemoveAfterTime(1.1))
        prox.engine:addEntity(e_flash)

        self:wait(battle, 1.0)
        battle.actions = battle.actions - 1

        prox.events:fireEvent(BattleLogEvent({{1,1,1}, player.name.." played ", {0.95, 0.6, 0.6}, card.name, {1,1,1}, "."}))

    elseif battle.state == Battle.static.STATE_REACT
    and event.player ~= battle.current_player then
        local player = battle.players[event.player]
        assert(event.card >= 1 and event.card <= #player.hand, "Invalid hand card index.")
        local card = player.hand[event.card]
        local hand = battle.hands[event.player]

        battle.damage = math.max(battle.damage - card.block, 0)

        local variables = {}
        self:reactCard(battle, card, {})

        table.remove(player.hand, event.card)
        if not card:isToken() then
            table.insert(player.discard, 1, card)
        end
        prox.engine:removeEntity(hand.cards[event.card])
        table.remove(hand.cards, event.card)

        hand.state = Hand.static.STATE_INACTIVE
        battle.state = Battle.static.STATE_REACT_DAMAGE

        prox.events:fireEvent(BattleLogEvent(string.format("%s reacted with %s.", player.name, card.name)))
    end
end

--- Execute card's active effects.
-- @param battle Current @{components.battle.Battle} instance.
-- @param card @{cards.Card} instance to play.
-- @param variables Table of current battle variables.
function BattleSystem:playCard(battle, card, variables)
    assert(#battle.effects == 0, "Card active effect played while effects queue is not empty.")
    for _, v in ipairs(card.active) do
        v:apply(variables, false, battle.effects)
    end
end

--- Execute card's reactive effects.
-- @param battle Current @{components.battle.Battle} instance.
-- @param card @{cards.Card} instance to play.
-- @param variables Table of current battle variables.
function BattleSystem:reactCard(battle, card, variables)
    local top_effects = {}
    for _, v in ipairs(card.reactive) do
        v:apply(variables, true, top_effects)
    end
    for i=#top_effects, 1, -1 do
        table.insert(battle.effects, 1, top_effects[i])
    end
end

--- Get card effect target matching target string.
-- @param battle Current @{components.battle.Battle} instance.
-- @param target Target string.
-- @param reactive True if card is played reactively.
-- @return A @{components.battle.Player} instance.
function BattleSystem:getTarget(battle, target, reactive)
    if not reactive then
        if target == "self" then
            return battle:currentPlayer()
        elseif target == "enemy" then
            return battle:opponentPlayer()
        end
    else
        if target == "self" then
            return battle:opponentPlayer()
        elseif target == "enemy" then
            return battle:currentPlayer()
        end
    end
    error(string.format("Invalid card effect target."))
end

function BattleSystem:resolve(battle)
    local e = battle.effects[1]
    table.remove(battle.effects, 1)

    local target = self:getTarget(battle, e.target, e.reactive)
    local effect = e.effect

    local type = effect.type
    if type == "deal" then
        self:effectDealCards(battle, target, effect.card, effect.pile, effect.count)
    elseif type == "draw" then
        self:effectDrawCards(battle, target, effect.count)
    elseif type == "discard" then
        self:effectDiscardCards(battle, target, effect.count)
    elseif type == "hit" then
        if not e.reactive and e.target == "enemy" and self:playerCanBlock(target) then
            battle.damage = effect.count
            battle:opponentHand().state = Hand.static.STATE_REACT
            battle.state = Battle.static.STATE_REACT
        else
            self:hitPlayer(battle, target, effect.count)
        end
    elseif type == "replace" then
        self:effectReplaceCards(battle, target, effect.card, effect.count)
    elseif type == "restore" then
        self:effectRestoreCards(battle, target, effect.count)
    elseif type == "gainaction" then
        self:effectGainActions(battle, target, effect.count)
    else
        error(string.format("Unknown card effect type: \"%s\"", type))
    end
end

function BattleSystem:effectDrawCards(battle, player, count, silent)
    if count <= 0 then return end

    for i=1, count do
        local card = player:draw()
        if card == nil then
            break
        end
        local e = self:makeCard(battle, player, card)
        local hand = battle.hands[player.id]
        table.insert(hand.cards, e)
        table.insert(player.hand, card)
    end

    --self:makeIndicator(battle, player, Indicator.static.TYPE_DRAW, count)
    if not silent then
        prox.events:fireEvent(BattleLogEvent(string.format("%s drew %d cards.", player.name, count)))
    end
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

    self:makeIndicator(battle, player, Indicator.static.TYPE_DISCARD, count)
    prox.events:fireEvent(BattleLogEvent(string.format("%s discarded %d cards.", player.name, count)))
end

function BattleSystem:effectDealCards(battle, player, card_id, pile, count)
    local card = battle.card_index[card_id]
    for i=1, count do
        if pile == "hand" then
            table.insert(player.hand, card)
            local e = self:makeCard(battle, player, card)
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

    self:makeIndicator(battle, player, Indicator.static.TYPE_DEAL, count)
    prox.events:fireEvent(BattleLogEvent(string.format("%s received %d %s tokens to %s.", player.name, count, card.name, pile)))
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
    prox.events:fireEvent(BattleLogEvent(string.format("%s had %d cards replaced with %s tokens.", player.name, count, card.name)))
end

function BattleSystem:effectRestoreCards(battle, player, count)
    count = math.min(count, #player.wounded)
    for i=1, count do
        local card = player.wounded[1]
        table.remove(player.wounded, 1)
        table.insert(player.discard, 1, card)
    end

    self:makeIndicator(battle, player, Indicator.static.TYPE_RESTORE, count)
    prox.events:fireEvent(BattleLogEvent(string.format("%s restored %d wounded cards.", player.name, count)))
end

function BattleSystem:effectGainActions(battle, player, count)
    battle.actions = battle.actions + count
    self:makeIndicator(battle, battle:currentPlayer(), Indicator.static.TYPE_GAIN_ACTION, count)
    prox.events:fireEvent(BattleLogEvent(string.format("%s gained %d actions.", player.name, count)))
end

function BattleSystem:hitPlayer(battle, player, damage)
    local hand = battle.hands[player.id]
    local hits = player:hit(damage)
    self:makeIndicator(battle, player, Indicator.static.TYPE_DAMAGE, damage)
    prox.events:fireEvent(BattleLogEvent(string.format("%s took %d damage.", player.name, damage)))
end

function BattleSystem:playerCanBlock(player)
    for _, card in ipairs(player.hand) do
        if card.block ~= nil then
            return true
        end
    end
    return false
end

function BattleSystem:endTurn(battle)
    battle.current_player = battle.current_player % 2 + 1
    battle.state = Battle.static.STATE_PREPARE
end

function BattleSystem:endReact(battle)
    battle:opponentHand().state = Hand.static.STATE_INACTIVE
    Battle.state = Battle.static.STATE_REACT_DAMAGE
end

function BattleSystem:makeIndicator(battle, player, type, value)
    local e = Entity()
    e:add(prox.Tween())

    local x, y
    if player.id == 1 then
        x, y = prox.window.getWidth()-55, prox.window.getHeight()-55
    else
        x, y = 55, 55
    end
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

function BattleSystem:makeCard(battle, player, card)
    local x, y, z = prox.window.getWidth()/2, prox.window.getHeight()/2, 1
    local e = Entity()
    e:add(prox.Transform(x, y, z))
    e:add(prox.Tween())
    e:add(prox.Sprite({image=AssetManager.getCardImagePath("_backside_")}))
    e:add(prox.Animator(AssetManager.getCardAnimator(card.id)))
    e:add(Card(card, 1))
    if player.id == 1 then
        e:get("Tween"):add(0.5, e:get("components.battle.Card"), {dir=0}, "inOutQuad")
    end
    prox.engine:addEntity(e)
    return e
end

function BattleSystem:wait(battle, time)
    battle.wait = math.max(battle.wait, time)
end

return BattleSystem

--- In-battle controller system.
-- @classmod systems.logic.BattleSystem
local BattleSystem = class("systems.logic.BattleSystem", System)

local Battle = require("components.battle.Battle")
local Card = require("components.battle.Card")
local Indicator = require("components.battle.Indicator")

local TargetEffect = require("cards.TargetEffect")
local CardEffect = require("cards.CardEffect")

local SelectTargetEvent = require("events.SelectTargetEvent")
local MAX_ACTIONS = 5
local HAND_SIZE = 5

local function make_card_entity(battle, card, x, y, z)
    local e = Entity()
    e:add(prox.Transform(x, y, z))
    e:add(prox.Sprite(AssetManager.getCardImage(card.id)))
    e:add(Card(card))

    local hand = battle.hand:get("components.battle.Hand")
    table.insert(hand.cards, e)
    prox.engine:addEntity(e)
    return e
end

local function make_indicator_entity(battle, player, type, value, token)
    for i=1,2 do
        for j=1,#battle.party[i] do
            if player == battle.party[i][j] then
                local e = Entity()
                e:add(prox.Tween())

                local x, y, targetx, targety
                if type == Indicator.static.TYPE_DEAL then
                    x, y = prox.window.getWidth()/2, prox.window.getHeight()/2-40
                    targetx, targety = 50+(i-1)*540, 49+(j-1)*78
                    e:add(prox.Transform(x, y))
                    e:add(Indicator(type, 1.5, value, token))

                    e:get("Tween"):add(0.75, e:get("Transform"), {x=targetx, y=targety}, "inOutQuad")
                else
                    x, y = 50+(i-1)*540, 52+(j-1)*78
                    targetx, targety = x, y-5
                    e:add(prox.Transform(x, y))
                    e:add(Indicator(type, 1.5, value))
                    e:get("Tween"):add(0.5, e:get("Transform"), {x=targetx, y=targety}, "outQuad")
                    e:get("Tween"):add(1.0, e:get("components.battle.Indicator"), {alpha=0},
                        function(t,b,c,d) return prox.tween.easing.linear(t*2-d,b,c,d)
                    end)
                end
                prox.engine:addEntity(e)
                return e
            end
        end
    end
    error("Trying to add indicator for unknown player")
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
    local text_font = prox.resources.getFont("data/fonts/Lato-Regular.ttf", 10)
    local title_font = prox.resources.getFont("data/fonts/Lato-Black.ttf", 13)
    local img_portrait = prox.resources.getImage("data/images/portrait.png")
    local img_portrait_dead = prox.resources.getImage("data/images/portrait_dead.png")
    local img_portrait_active = prox.resources.getImage("data/images/portrait_active.png")
    local img_portrait_target = prox.resources.getImage("data/images/portrait_target.png")

    prox.resources.setFont(text_font)

    for _, e in pairs(self.targets) do
        local battle = e:get("components.battle.Battle")

        if battle.state == Battle.static.STATE_INIT then
            battle.state = Battle.static.STATE_PREPARE

            for _,party in ipairs(battle.party) do
                for _,player in ipairs(party) do
                    while #player.hand < HAND_SIZE and #player.deck > 0 do
                        player:draw()
                    end
                end
            end

        elseif battle.state == Battle.static.STATE_PREPARE then
            local player = battle:currentPlayer()
            local hand = battle.hand:get("components.battle.Hand")
            for _, v in ipairs(hand.cards) do
                prox.engine:removeEntity(v)
            end
            hand.cards = {}
            hand.active = nil

            for i, card in ipairs(player.hand) do
                make_card_entity(battle, card, prox.window.getWidth()/2, prox.window.getHeight()+50, 1 - (i-1) / #player.hand)
            end


            if #player.hand < HAND_SIZE then
                self:drawCard(battle, player, HAND_SIZE-#player.hand)
            end

            battle.state = Battle.static.STATE_PLAY_CARD

        elseif battle.state == Battle.static.STATE_PLAY_CARD then
            if prox.gui.Button("End turn", {font=title_font}, 8, prox.window.getHeight()-30, 70, 24).hit then
                self:endTurn(battle)
            end

        elseif battle.state == Battle.static.STATE_RESOLVE then
            if #battle.effects > 0 then
                self:resolve(battle)
            else
                if battle.phase == Battle.static.PHASE_ACTIVE then
                    battle.state = Battle.static.STATE_PLAY_CARD
                    local _, hand = next(prox.engine:getEntitiesWithComponent("components.battle.Hand"))
                    hand = hand:get("components.battle.Hand")
                    prox.engine:removeEntity(hand.active)
                    hand.active = nil
                else
                end
            end

        elseif battle.state == Battle.static.STATE_TARGET then
            prox.gui.Label("Select target!", {font=title_font}, prox.window.getWidth()/2-100, prox.window.getHeight()/2-140, 200, 20)
            local effect_text = self:getEffectText(battle)
            prox.gui.Label(effect_text, {font=text_font}, prox.window.getWidth()/2-100, prox.window.getHeight()/2-120, 200, 20)
        end

        for i=1,2 do
            prox.gui.layout:reset(74+(i-1)*372, 27, 4, 4)
            for j=1,#battle.party[i] do
                if battle.state == Battle.static.STATE_TARGET and battle.party[i][j].alive then
                    if prox.gui.ImageButton(img_portrait_target, 10+(i-1)*540, 10+(j-1)*78).hit then
                        prox.events:fireEvent(SelectTargetEvent(i, j))
                    end
                end
                if battle.party[i][j] == battle:currentPlayer() then
                    prox.gui.Image(img_portrait_active, 12+(i-1)*540, 12+(j-1)*78)
                elseif battle.party[i][j].alive == true then
                    prox.gui.Image(img_portrait, 12+(i-1)*540, 12+(j-1)*78)
                else
                    prox.gui.Image(img_portrait_dead, 12+(i-1)*540, 12+(j-1)*78)
                end

                local p = battle.party[i][j]
                prox.gui.Label(p.name,                    prox.gui.layout:row(120, 8))
                prox.gui.Label("Hand: " .. #p.hand,       prox.gui.layout:row())
                prox.gui.Label("Deck: " .. #p.deck,       prox.gui.layout:row())
                prox.gui.Label("Discard: " .. #p.discard, prox.gui.layout:row())
                prox.gui.layout:row(120, 26)
            end
        end
    end
end

function BattleSystem:onPlayCard(event)
    for _, e in pairs(self.targets) do
        local battle = e:get("components.battle.Battle")
        if battle.state == Battle.static.STATE_PLAY_CARD then
            local player = battle:currentPlayer()
            assert(event.card >= 1 and event.card <= #player.hand, "Invalid hand card index.")

            battle.effects = {}
            local variables = {}
            local card = player.hand[event.card]
            table.remove(player.hand, event.card)
            table.insert(player.discard, 1, card)
            self:playCard(card, {}, battle.effects)

            local hand = battle.hand:get("components.battle.Hand")
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
        return {battle:currentPlayer()}
    elseif target == "target" then
        return {battle.target}
    elseif target == "party" then
        return battle.party[battle.current_party]
    elseif target == "enemies" then
        return battle.party[(battle.current_party % 2)+1]
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
                self:dealCard(battle, target, effect.card, effect.pile, effect.count)
            end
        elseif type == "draw" then
            for _, target in ipairs(targets) do
                self:drawCard(battle, target, effect.count)
            end
        elseif type == "hit" then
            for _, target in ipairs(targets) do
                self:hitPlayer(battle, target, effect.count)
            end
        elseif type == "replace" then
            error("\"replace\" card effect not implemented.")
        elseif type == "restore" then
            error("\"restore\" card effect not implemented.")
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
    repeat
        battle.current_player = battle.current_player + 1
        if battle.current_player > #battle:currentParty() then
            battle.current_party = (battle.current_party % 2) + 1
            battle.current_player = 1
        end
    until battle:currentPlayer().alive == true
    battle.state = Battle.static.STATE_PREPARE
end

function BattleSystem:drawCard(battle, player, count)
    for i=1, count do
        local card = player:draw()
        if card == nil then
            return
        end
        if player == battle:currentPlayer() then
            make_card_entity(battle, card, prox.window.getWidth()-38, prox.window.getHeight()-51, i)
        end
    end

    make_indicator_entity(battle, player, Indicator.static.TYPE_DRAW, count)
end

function BattleSystem:dealCard(battle, player, id, pile, count)
    local card = battle.card_index[id]
    for i=1, count do
        if pile == "hand" then
            table.insert(player.hand, card)
        elseif pile == "deck" then
            table.insert(player.deck, 1, card)
        elseif pile == "discard" then
            table.insert(player.discard, 1, card)
        else
            error(string.format("Unknown card pile target: \"%s\"", pile))
        end

        if player == battle:currentPlayer() and pile == "hand" then
            make_card_entity(battle, card, prox.window.getWidth() / 2, prox.window.getHeight() / 2 - 40)
        end
    end

    if player ~= battle:currentPlayer() or pile ~= "hand"then
        make_indicator_entity(battle, player, Indicator.static.TYPE_DEAL, count, id)
    end
end

function BattleSystem:hitPlayer(battle, player, damage)
    local hand = battle.hand:get("components.battle.Hand")
    local drawn = 0
    for i=1, damage do
        local index = player:hit()
        if index ~= nil and player == battle:currentPlayer() then
            local e = hand.cards[index]
            table.remove(hand.cards, index)
            prox.engine:removeEntity(e)
            drawn = drawn + 1
        end
    end

    if drawn > 0 then
        make_indicator_entity(battle, player, Indicator.static.TYPE_DAMAGE, damage)
    end
end

return BattleSystem

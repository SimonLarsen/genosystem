--- In-battle system.
-- @classmod systems.logic.BattleSystem
local BattleSystem = class("systems.logic.BattleSystem", System)

local Battle = require("components.battle.Battle")
local Card = require("components.battle.Card")

local TargetEffect = require("cards.TargetEffect")
local CardEffect = require("cards.CardEffect")

local SelectTargetEvent = require("events.SelectTargetEvent")
local MAX_ACTIONS = 5
local HAND_SIZE = 5

function BattleSystem:initialize()
    System.initialize(self)
end

function BattleSystem:requires()
    return {"components.battle.Battle"}
end

function BattleSystem:update(dt)
    local text_font = prox.resources.getFont("data/fonts/Lato-Regular.ttf", 10)
    local title_font = prox.resources.getFont("data/fonts/Lato-Black.ttf", 13)
    local img_portrait = prox.resources.getImage("data/images/portrait.png")
    local img_portrait_select = prox.resources.getImage("data/images/portrait_select.png")

    prox.resources.setFont(text_font)

    for _, e in pairs(self.targets) do
        local battle = e:get("components.battle.Battle")

        -- start of battle
        if battle.state == Battle.static.STATE_INIT then
            battle.state = Battle.static.STATE_PREPARE

            for _,party in ipairs(battle.party) do
                for _,player in ipairs(party) do
                    while player.hand:size() < HAND_SIZE do
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

            for i, card in ipairs(player.hand:getCards()) do
                local e = Entity()
                e:add(prox.Transform(prox.window.getWidth()/2, prox.window.getHeight()+50, 1 - (i-1) / player.hand:size()))
                e:add(prox.Sprite(AssetManager.getCardImage(card.id)))
                e:add(Card(card))
                local t = e:get("Transform")

                table.insert(hand.cards, e)
                prox.engine:addEntity(e)
            end
            battle.state = Battle.static.STATE_PLAY

        elseif battle.state == Battle.static.STATE_PLAY then
            if prox.gui.Button("End turn", {font=title_font}, 8, prox.window.getHeight()-30, 70, 24).hit then
                self:endTurn(battle)
            end

        elseif battle.state == Battle.static.STATE_RESOLVE then
            if #battle.effects == 0 then
                battle.state = Battle.static.STATE_PREPARE
                local _, hand = next(prox.engine:getEntitiesWithComponent("components.battle.Hand"))
                hand = hand:get("components.battle.Hand")
                prox.engine:removeEntity(hand.active)
                hand.active = nil
            else
                self:resolve(battle)
            end

        elseif battle.state == Battle.static.STATE_TARGET then
            prox.gui.Label("Select target!", {font=title_font}, prox.window.getWidth()/2-100, prox.window.getHeight()/2-140, 200, 20)
            local effect_text = self:getEffectText(battle)
            prox.gui.Label(effect_text, {font=text_font}, prox.window.getWidth()/2-100, prox.window.getHeight()/2-120, 200, 20)
        end

        for i=1,2 do
            prox.gui.layout:reset(74+(i-1)*372, 27, 4, 4)
            for j=1,#battle.party[i] do
                prox.gui.Image(img_portrait, 12+(i-1)*540, 12+(j-1)*78)
                if battle.state == Battle.static.STATE_TARGET then
                    if prox.gui.ImageButton(img_portrait_select, 9+(i-1)*540, 9+(j-1)*78).hit then
                        prox.events:fireEvent(SelectTargetEvent(i, j))
                    end
                end

                local p = battle.party[i][j]
                prox.gui.Label("Hand: " .. p.hand:size(),       prox.gui.layout:row(120, 8))
                prox.gui.Label("Deck: " .. p.deck:size(),       prox.gui.layout:row())
                prox.gui.Label("Discard: " .. p.discard:size(), prox.gui.layout:row())
                prox.gui.Label("Wounded: " .. p.wounded:size(), prox.gui.layout:row())
                prox.gui.layout:row(120, 26)
            end
        end
    end
end

function BattleSystem:onPlayCard(event)
    for _, e in pairs(self.targets) do
        local battle = e:get("components.battle.Battle")
        if battle.state == Battle.static.STATE_PLAY then
            local player = battle:currentPlayer()
            assert(event.card >= 1 and event.card <= player.hand:size(), "Invalid hand card index.")

            battle.effects = {}
            local variables = {}
            local card = player.hand:draw(event.card)
            self:playCard(card, {}, battle.effects)
            player.discard:addCard(card)

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
    if e:isInstanceOf(CardEffect) then
        local targets = self:getTargets(battle, e.target)
        e.effect:apply(targets, battle.card_index)
    elseif e:isInstanceOf(TargetEffect) then
        battle.state = Battle.static.STATE_TARGET
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
    battle.current_player = battle.current_player + 1
    if battle.current_player > #battle:currentParty() then
        battle.current_party = (battle.current_party % 2) + 1
        battle.current_player = 1
    end
    battle.state = Battle.static.STATE_PREPARE
end

return BattleSystem

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

    self.font = prox.resources.getFont("data/fonts/Lato-Regular.ttf", 10)
    self.img_portait = prox.resources.getImage("data/images/portrait.png")
end

function BattleSystem:requires()
    return {"components.battle.Battle"}
end

function BattleSystem:update(dt)
    prox.resources.setFont(self.font)

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

            local player = battle:currentPlayer()
            for i, card in ipairs(player.hand:getCards()) do
                local e = Entity()
                e:add(prox.Transform(prox.window.getWidth()/2, prox.window.getHeight()+50, 1 - (i-1) / player.hand:size()))
                e:add(prox.Sprite(AssetManager.getCardImage(card.id)))
                e:add(Card(card))

                local hand = battle.hand:get("components.battle.Hand")
                table.insert(hand.cards, e)
                prox.engine:addEntity(e)
            end

        elseif battle.state == Battle.static.STATE_PREPARE then
            battle.state = Battle.static.STATE_PLAY

        elseif battle.state == Battle.static.STATE_PLAY then
            if prox.gui.Button("Done!", 8, prox.window.getHeight()-26, 50, 20).hit then
            end

        elseif battle.state == Battle.static.STATE_RESOLVE then
            if #battle.effects == 0 then
                battle.state = Battle.static.STATE_PLAY
            else
                self:resolve(battle)
            end

        elseif battle.state == Battle.static.STATE_TARGET then
            prox.gui.Label("Select target!", prox.window.getWidth()/2-100, prox.window.getHeight()/2-40, 200, 80)
        end

        for i=1,2 do
            prox.gui.layout:reset(74+(i-1)*372, 27, 4, 4)
            for j=1,#battle.party[i] do
                if prox.gui.ImageButton(self.img_portait, 12+(i-1)*540, 12+(j-1)*78).hit then
                    if battle.state == Battle.static.STATE_TARGET then
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
            prox.engine:removeEntity(hc)
            table.remove(hand.cards, event.card)
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

return BattleSystem

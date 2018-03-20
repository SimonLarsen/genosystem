--- In-battle system.
-- @classmod systems.logic.BattleSystem
local BattleSystem = class("systems.logic.BattleSystem", System)

local Battle = require("components.battle.Battle")
local TargetEffect = require("cards.TargetEffect")
local CardEffect = require("cards.CardEffect")

local MAX_ACTIONS = 5
local HAND_SIZE = 5

function BattleSystem:initialize()
    System.initialize(self)

    self.font = love.graphics.newFont(10)
end

local function get_targets(battle, target)
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

function BattleSystem:update(dt)
    love.graphics.setFont(self.font)

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
            while player.hand:size() < HAND_SIZE do
                player:draw()
            end
            battle.state = Battle.static.STATE_PLAY
            battle.actions = MAX_ACTIONS

        elseif battle.state == Battle.static.STATE_PLAY then
            local player = battle:currentPlayer()

            if prox.gui.Button("Done!", 16, 336, 100, 20).hit or battle.actions == 0 then
                battle.current_player = battle.current_player + 1
                if battle.current_player > #battle:currentParty() then
                    battle.current_party = (battle.current_party % 2) + 1
                    battle.current_player = 1
                end
                battle.state = Battle.static.STATE_PREPARE
            end

            prox.gui.Label("Actions: " .. battle.actions, 16, 316, 100, 20)

            prox.gui.layout:reset(16, 16, 4, 4)
            local play_card = nil
            for i, card in ipairs(player.hand:getCards()) do
                if prox.gui.Button(card.text, {id="card"..i}, prox.gui.layout:row(160, 40)).hit then
                    play_card = i
                    break
                end
            end

            if play_card then
                local variables = {} -- TODO: Populate variable table
                battle.effects = {}
                local card = player.hand:draw(play_card)
                card:play(variables, battle.effects)

                battle.actions = battle.actions - 1
                battle.state = Battle.static.STATE_RESOLVE
            end

        elseif battle.state == Battle.static.STATE_RESOLVE then
            if #battle.effects == 0 then
                battle.state = Battle.static.STATE_PLAY
            else
                local effect = battle.effects[1]
                table.remove(battle.effects, 1)

                if effect:isInstanceOf(TargetEffect) then
                    battle.state = Battle.static.STATE_TARGET
                elseif effect:isInstanceOf(CardEffect) then
                    local targets = get_targets(battle, effect.target)
                    effect.effect:apply(targets, battle.card_index)
                end
            end

        elseif battle.state == Battle.static.STATE_TARGET then
            for i=1,2 do
                for j=1,#battle.party[i] do
                    local p = battle.party[i][j]
                    if prox.gui.Button(p.name, 316+(i-1)*120, 16+(j-1)*100, 108, 10).hit then
                        battle.target = p
                        battle.state = Battle.static.STATE_RESOLVE
                    end
                end
            end
        end

        for i=1,2 do
            prox.gui.layout:reset(320+(i-1)*120, 16, 4, 4)
            for j=1,#battle.party[i] do
                local p = battle.party[i][j]
                if i == battle.current_party and j == battle.current_player then
                    prox.gui.Label("### " .. p.name .. " ###", prox.gui.layout:row(100, 10))
                else
                    prox.gui.Label("- " .. p.name .. " -", prox.gui.layout:row(100, 10))
                end
                prox.gui.Label("Hand: " .. p.hand:size(),       prox.gui.layout:row())
                prox.gui.Label("Deck: " .. p.deck:size(),       prox.gui.layout:row())
                prox.gui.Label("Discard: " .. p.discard:size(), prox.gui.layout:row())
                prox.gui.Label("Wounded: " .. p.wounded:size(), prox.gui.layout:row())
                prox.gui.layout:row(100, 40)
            end
        end
    end
end

function BattleSystem:requires()
    return {"components.battle.Battle"}
end

return BattleSystem

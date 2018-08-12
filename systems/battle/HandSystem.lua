--- In-battle hand management.
-- @classmod systems.battle.HandSystem
local HandSystem = class("systems.battle.HandSystem", System)

local Hand = require("components.battle.Hand")
local PlayCardEvent = require("events.PlayCardEvent")
local DescriptionBoxEvent = require("events.DescriptionBoxEvent")

local MAX_WIDTH = 225

function HandSystem:initialize()
    System.initialize(self)
end

function HandSystem:update(dt)
    local text_font = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 10)
    local title_font = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 13)

    for _, e in pairs(self.targets) do
        local hand = e:get("components.battle.Hand")
        local handpos = e:get("Transform")
        local ncards = #hand.cards

        local hover_card = nil
        local mindist = 999999

        local mx, my = prox.mouse.getPosition()

        -- find hovered card
        if hand.player == 1 and hand.state ~= Hand.static.STATE_INACTIVE then
            for i, card in ipairs(hand.cards) do
                local t = card:get("Transform")
                local dx = math.abs(mx - t.x)
                local dy = math.abs(my - t.y)
                if dy <= 48 and dx <= 36 and dx < mindist then
                    mindist = dx
                    hover_card = i
                end
            end
        end

        for i, card in ipairs(hand.cards) do
            local c = card:get("components.battle.Card")

            -- space out cards
            local offset
            if ncards > 1 then
                offset = (i-1) / (ncards-1) * 2 - 1
            else
                offset = 0
            end
            local hand_width = math.max(math.min((ncards-1) * 74, MAX_WIDTH), 10)

            local target_x = handpos.x + offset*hand_width/2
            local target_y = handpos.y
            local target_z = i

            local col = card:get("Sprite").color
            if hand.player == 1 and hand.state == Hand.static.STATE_REACT and not c.card.block then
                col[1], col[2], col[3] = 0.4, 0.4, 0.4
                target_y = target_y + 10
                card:get("Transform").z = i + 10
            else
                col[1], col[2], col[3] = 1, 1, 1
            end

            -- move hovered card up
            if i == hover_card then
                target_y = target_y - 10
                target_z = 0
            end

            local t = card:get("Transform")
            local speed = math.min(10*math.sqrt((t.x-target_x)^2 + (t.y-target_y)^2), 700)
            t.x, t.y = prox.math.movetowards2(t.x, t.y, target_x, target_y, speed*dt)
            t.z = target_z
        end

        if hover_card then
            if hover_card ~= hand.hover_card then
                local id = hand.cards[hover_card]:get("components.battle.Card").card.id
                prox.events:fireEvent(DescriptionBoxEvent(true, "hand", "card", id))
                hand.hover_card = hover_card
            end
            if prox.mouse.wasPressed(1) then
                prox.events:fireEvent(PlayCardEvent(hand.player, hover_card))
                prox.events:fireEvent(DescriptionBoxEvent(false, "hand"))
                hand.hover_card = nil
            end
        else
            if hand.hover_card then
                prox.events:fireEvent(DescriptionBoxEvent(false, "hand"))
                hand.hover_card = nil
            end
        end
    end
end

function HandSystem:requires()
    return {"components.battle.Hand","Transform"}
end

return HandSystem

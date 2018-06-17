--- In-battle hand management.
-- @classmod systems.logic.HandSystem
local HandSystem = class("systems.logic.HandSystem", System)

local Hand = require("components.battle.Hand")
local PlayCardEvent = require("events.PlayCardEvent")

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

            c.target.x = handpos.x + offset*hand_width/2
            c.target.y = handpos.y
            card:get("Transform").z = i

            local col = card:get("Sprite").color
            if hand.state == Hand.static.STATE_REACT and not c.card.block then
                col[1], col[2], col[3] = 0.4, 0.4, 0.4
                c.target.y = c.target.y + 10
                card:get("Transform").z = i + 10
            else
                col[1], col[2], col[3] = 1, 1, 1
            end

            -- move hovered card up
            if i == hover_card then
                c.target.y = c.target.y - 10
                card:get("Transform").z = 0
            end
        end

        if hover_card then
            local card = hand.cards[hover_card]
            local cc = card:get("components.battle.Card").card
            local t = card:get("Transform")
            prox.gui.Label(cc:getText(), prox.window.getWidth()/2-120, prox.window.getHeight()/2-20, 240, 60)
            prox.gui.Label(cc.name, {font=title_font}, prox.window.getWidth()/2-60, prox.window.getHeight()/2-40, 120, 20)

            if prox.mouse.wasPressed(1) then
                prox.events:fireEvent(PlayCardEvent(hand.player, hover_card))
            end
        end
    end
end

function HandSystem:requires()
    return {"components.battle.Hand","Transform"}
end

return HandSystem

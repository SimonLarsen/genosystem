--- In-battle hand management.
-- @classmod systems.logic.HandSystem
local HandSystem = class("systems.logic.HandSystem", System)

local PlayCardEvent = require("events.PlayCardEvent")

function HandSystem:initialize()
    System.initialize(self)
end

function HandSystem:update(dt)
    local text_font = prox.resources.getFont("data/fonts/Lato-Regular.ttf", 10)
    local title_font = prox.resources.getFont("data/fonts/Lato-Black.ttf", 13)

    for _, e in pairs(self.targets) do
        local hand = e:get("components.battle.Hand")
        local ncards = #hand.cards

        local hover_card = nil
        local mindist = 999999

        local mx, my = prox.mouse.getPosition()

        if hand.active then
            local c = hand.active:get("components.battle.Card")
            c.targetx = prox.window.getWidth() / 2
            c.targety = prox.window.getHeight() / 2 - 40
        else
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

            local offset = (i-1) / (ncards-1) * 2 - 1
            local hand_width = math.max(math.min((ncards-1) * 72, 300), 10)

            c.targetx = prox.window.getWidth()/2 + offset*hand_width/2
            c.targety = prox.window.getHeight() - 60
            if i == hover_card then
                c.targety = c.targety - 10
            end

            if hover_card then
                card:get("Transform").z = math.abs(i - hover_card)
            end
        end

        if hover_card then
            local card = hand.cards[hover_card]
            local cc = card:get("components.battle.Card").card
            local t = card:get("Transform")
            prox.gui.Label(cc.text, prox.window.getWidth()/2-60, prox.window.getHeight()/2-110, 120, 120)
            prox.gui.Label(cc.name, {font=title_font}, prox.window.getWidth()/2-60, prox.window.getHeight()/2-140, 120, 20)

            if prox.mouse.wasPressed(1) then
                prox.events:fireEvent(PlayCardEvent(hover_card))
            end
        end
    end
end

function HandSystem:requires()
    return {"components.battle.Hand"}
end

return HandSystem

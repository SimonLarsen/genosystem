--- In-batle card visualization system.
-- @classmod systems.logic.CardSystem
local CardSystem = class("systems.logic.CardSystem", System)

function CardSystem:initialize()
    System.initialize(self)
end

function CardSystem:update(dt)
    for _,e in pairs(self.targets) do
        local t = e:get("Transform")
        local card = e:get("components.battle.Card")

        local speed = math.min(10*math.sqrt((t.x-card.target.x)^2 + (t.y-card.target.y)^2), 700)
        t.x, t.y = prox.math.movetowards2(t.x, t.y, card.target.x, card.target.y, speed*dt)

        card.dir = prox.math.movetowards(card.dir, card.target_dir, 2*dt)
        e:get("Animator"):setProperty("dir", card.dir)
        if e:get("Sprite") then
            e:get("Sprite").sx = math.abs(math.cos(card.dir * math.pi))
        end
    end
end

function CardSystem:requires()
    return {"Transform","components.battle.Card"}
end

return CardSystem

--- In-batle card visualization system.
-- @classmod systems.logic.CardSystem
local CardSystem = class("systems.logic.CardSystem", System)

function CardSystem:initialize()
    System.initialize(self)
end

function CardSystem:update(dt)
    for _,e in pairs(self.targets) do
        local card = e:get("components.battle.Card")

        e:get("Animator"):setProperty("dir", card.dir)
        if e:get("Sprite") then
            e:get("Sprite").sx = math.abs(math.cos(card.dir * math.pi)) * card.zoom
            e:get("Sprite").sy = card.zoom
        end
    end
end

function CardSystem:requires()
    return {"Transform","components.battle.Card"}
end

return CardSystem

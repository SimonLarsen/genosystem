local IndicatorSystem = class("systems.graphics.IndicatorSystem", System)

local Indicator = require("components.battle.Indicator")

function IndicatorSystem:initialize()
    System.initialize(self)
end

function IndicatorSystem:requires()
    return {"components.battle.Indicator"}
end

function IndicatorSystem:update(dt)
    local font = prox.resources.getFont("data/fonts/Lato-Black.ttf", 16)

    for _, e in pairs(self.targets) do
        local t = e:get("Transform")
        local indicator = e:get("components.battle.Indicator")
        prox.gui.Label(tostring(indicator.value), {font=font, color={normal={fg={212, 22, 22}}}}, t.x-38, t.y-37, 76, 74)
        indicator.time = indicator.time - dt
        if indicator.time <= 0 then
            prox.engine:removeEntity(e)
        end
    end
end

return IndicatorSystem

--- System handling in-battle effect indicators.
-- @classmod systems.graphics.IndicatorSystem
local IndicatorSystem = class("systems.graphics.IndicatorSystem", System)

local Indicator = require("components.battle.Indicator")

local images = {
    [Indicator.static.TYPE_DAMAGE]  = "data/images/indicators/damage.png",
    [Indicator.static.TYPE_DRAW]    = "data/images/indicators/draw.png",
    [Indicator.static.TYPE_RESTORE] = "data/images/indicators/restore.png",
    [Indicator.static.TYPE_GAIN_ACTION] = "data/images/indicators/gainaction.png"
}

function IndicatorSystem:initialize()
    System.initialize(self)
end

function IndicatorSystem:requires()
    return {"components.battle.Indicator"}
end

function IndicatorSystem:update(dt)
    local font = prox.resources.getFont("data/fonts/Lato-Black.ttf", 16)
    local color = {normal={fg={255, 255, 255, 255}}}

    for _, e in pairs(self.targets) do
        local t = e:get("Transform")
        local indicator = e:get("components.battle.Indicator")

        local img
        if indicator.type == Indicator.static.TYPE_DEAL then
            img = AssetManager.getCardImage(indicator.token)
        else
            img = prox.resources.getImage(images[indicator.type])
        end

        local imgw, imgh = img:getDimensions()
        local x,y = math.floor(t.x+0.5), math.floor(t.y+0.5)
        love.graphics.setColor(255, 255, 255, indicator.alpha*255)
        prox.gui.Image(img, x-imgw/2, y-imgh/2)
        love.graphics.setColor(255, 255, 255, 255)

        color.normal.fg[4] = indicator.alpha*255
        prox.gui.Label(tostring(indicator.value), {font=font, color=color}, x-32, y-32, 64, 64)

        indicator.time = indicator.time - dt
        if indicator.time <= 0 then
            prox.engine:removeEntity(e)
        end
    end
end

return IndicatorSystem

--- Battle log system.
-- @classmod system.battle.BattleLogSystem
local BattleLogSystem = class("systems.battle.BattleLogSystem", System)

function BattleLogSystem:initialize()
    System.initialize(self)

    prox.events:addListener("events.BattleLogEvent", self, self.onMessage)
end

function BattleLogSystem:requires()
    return {"components.battle.BattleLog"}
end

function BattleLogSystem:update(dt)
    for _, e in pairs(self.targets) do
        local log = e:get("components.battle.BattleLog")

        local changed = false

        local inner_height = log.text_height + 2 * log.margin
        local bar_height = math.min(log.h / inner_height, 1) * log.h

        if prox.mouse.isDown(1) then
            local mx, my = prox.mouse.getPosition()
            if math.abs(log.x+log.w+6 - mx) <= 4 and my >= log.y and my <= log.y+log.h then
                log.scroll = (my - bar_height/2 - log.y) / log.h * inner_height
                changed = true
            end
        end

        local wheel = prox.mouse.getAxis("y")
        if wheel ~= 0 then
            log.scroll = log.scroll - 8 * wheel
            changed = true
        end

        if changed then
            log.locked = log.scroll >= inner_height - log.h
        end
        log.scroll = prox.math.cap(log.scroll, 0, inner_height - log.h)
    end
end

function BattleLogSystem:draw()
    for _, e in pairs(self.targets) do
        local log = e:get("components.battle.BattleLog")
        love.graphics.setFont(log.font)

        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.rectangle("line", log.x+1, log.y+1, log.w-1, log.h-1)

        local stencil_fun = function()
            love.graphics.rectangle("fill", log.x+1, log.y+1, log.w-2, log.h-2)
        end

        love.graphics.stencil(stencil_fun, "replace", 1)
        love.graphics.setStencilTest("greater", 0)

        love.graphics.setColor(1, 1, 1, 1)
        local inner_height = log.text_height + 2 * log.margin
        local scroll = prox.math.cap(log.locked and math.huge or log.scroll, 0, math.max(inner_height - log.h, 0))
        local y = log.y - scroll + log.margin

        for _, s in ipairs(log.messages) do
            love.graphics.printf(s, log.x+log.margin, y, log.w - 2*log.margin, "left")
            local linewidth, lines = log.font:getWrap(s, log.w-2*log.margin)
            y = y + log.font:getHeight() * #lines + 4
        end
        love.graphics.setStencilTest()

        local bar_height = math.min(log.h / inner_height, 1) * log.h
        local bar_y = scroll / inner_height * log.h

        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.rectangle("fill", log.x+log.w+2, log.y + bar_y, 8, bar_height)

        love.graphics.setColor(1, 1, 1, 1)
    end
end

function BattleLogSystem:onMessage(event)
    for _, e in pairs(self.targets) do
        local log = e:get("components.battle.BattleLog")

        local linewidth, lines = log.font:getWrap(event.text, log.w - 2 * log.margin)
        log.text_height = log.text_height + #lines * log.font:getHeight()
        if #log.messages > 0 then
            log.text_height = log.text_height + log.spacing
        end
        table.insert(log.messages, event.text)
    end
end

return BattleLogSystem

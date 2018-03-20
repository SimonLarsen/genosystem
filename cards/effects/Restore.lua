--- Card effect restoring wounded cards
-- @classmod cards.effects.Restore
local Restore = class("cards.effects.Restore")

function Restore:initialize(count)
    self.count = count
end

function Restore:getType()
    return "restore"
end

function Restore:apply(targets)
    for _,v in ipairs(targets) do
        for i=1,self.count do
            if v.wounded:size() > 0 then
                local card = v.wounded:draw(v.wounded:size())
                v.discard:addCard(card)
            end
        end
    end
end

return Restore

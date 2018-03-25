local AssetManager = class("core.AssetManager")

local MISSING_CARD = "data/images/cards/_missing_.png"

function AssetManager:getCard(id)
    local img = prox.resources.getImage("data/images/cards/" .. id .. ".png", false)
    if img == nil then
        img = prox.resources.getImage(MISSING_CARD)
    end
    return img
end

return AssetManager

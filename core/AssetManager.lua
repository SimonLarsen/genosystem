local AssetManager = class("core.AssetManager")

local MISSING_CARD_PATH = "data/images/cards/_missing_.png"

function AssetManager.getCardImagePath(id)
    local path = "data/images/cards/" .. id .. ".png"
    if not prox.resources.exists(path) then
        path = MISSING_CARD_PATH
    end
    return path
end

return AssetManager

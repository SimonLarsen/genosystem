--- Asset management class.
-- @classmod core.AssetManager
local AssetManager = class("core.AssetManager")

AssetManager.static.MISSING_CARD_PATH = "data/images/cards/_missing_.png"
AssetManager.static.MISSING_GEAR_PATH = "data/images/gear/_missing_.png"
AssetManager.static.DESTROYED_GEAR_PATH = "data/images/gear/_destroyed_.png"
AssetManager.static.HIDDEN_GEAR_PATH = "data/images/gear/_hidden_.png"

--- Retrieve path for card face image.
-- @param id Unique card ID.
function AssetManager.getCardImagePath(id)
    local path = "data/images/cards/" .. id .. ".png"
    if not prox.resources.exists(path) then
        path = AssetManager.static.MISSING_CARD_PATH
    end
    return path
end

--- Retrieve path for gear image.
-- @param id Unique gear ID.
function AssetManager.getGearImagePath(id)
    local path = "data/images/gear/" .. id .. ".png"
    if not prox.resources.exists(path) then
        path = AssetManager.static.MISSING_GEAR_PATH
    end
    return path
end

--- Create card animator instance from card id.
-- @param id Unique card ID.
function AssetManager.getCardAnimator(id)
    return {
        default = "front",

        states = {
            front = { image = AssetManager.getCardImagePath(id) },
            back  = { image = AssetManager.getCardImagePath("_backside_") }
        },

        properties = {
            dir = { value = 0 }
        },

        transitions = {
            { from = "front", to = "back",  property = "dir", predicate = function(a) return (a - 0.5) % 2 < 1.0 end },
            { from = "back",  to = "front", property = "dir", predicate = function(a) return (a - 0.5) % 2 > 1.0 end },
        }
    }
end

return AssetManager

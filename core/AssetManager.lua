--- Asset management class.
-- @classmod core.AssetManager
local AssetManager = class("core.AssetManager")

local MISSING_CARD_PATH = "data/images/cards/_missing_.png"

--- Retrieve path for card face image.
-- @param id Unique card ID.
function AssetManager.getCardImagePath(id)
    local path = "data/images/cards/" .. id .. ".png"
    if not prox.resources.exists(path) then
        path = MISSING_CARD_PATH
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

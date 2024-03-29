--- Gear description class.
-- @classmod core.Gear

local Gear = class("core.Gear")

--- Constructor.
-- @param id (string) Gear ID
-- @param name (string) Name of the gear
-- @param hp (number) Max health points
-- @param trigger (string) Trigger condition for card. One of "reveal", "attacked", "destroyed", and "active".
-- @param effect Effect tree
-- @param text (string) Gear effect description
-- @param description (string) Long gear lore description
function Gear:initialize(id, name, hp, trigger, effect, text, description)
    self.id = id
    self.name = name
    self.hp = hp
    self.trigger = trigger
    self.effect = effect
    self.text = text
    self.description = description

    self.destroyed = false
end

--- Get gear's unique ID.
-- @return (string) Gear ID.
function Gear:getID()
    return self.id
end

--- Get gear effect description.
-- @return Gear text.
function Gear:getText()
    return self.text
end

return Gear

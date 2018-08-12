--- Description box event.
-- @classmod events.DescriptionBoxEvent
local DescriptionBoxEvent = class("events.DescriptionBoxEvent")

--- Constructor
-- @param enter (boolean) True if object to describe was entered, false otherwise.
-- @param source (string) Source of request. One of {"hand", "log", "gear"}.
-- @param type (string) Type of object to describe. One of {"card", "gear"}.
-- @param id (string) Unique ID of object to describe.
function DescriptionBoxEvent:initialize(enter, source, type, id)
    self.enter = enter
    self.source = source
    self.type = type
    self.id = id
end

return DescriptionBoxEvent

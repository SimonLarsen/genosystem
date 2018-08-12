local DescriptionBox = class("components.battle.DescriptionBox")

function DescriptionBox:initialize(card_index, gear_index)
    self.card_index = card_index
    self.gear_index = gear_index

    self.id = nil
    self.type = nil
    self.source = nil
end

return DescriptionBox

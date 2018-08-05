--- Battle log component.
-- @classmod components.battle.BattleLog
local BattleLog = class("components.battle.BattleLog")

function BattleLog:initialize(card_index, x, y, w, h)
    self.card_index = card_index
    self.messages = {}
    self.x = x or 5
    self.y = y or prox.window.getHeight()/2 - 60
    self.w = w or 180
    self.h = h or 120
    self.margin = 5
    self.spacing = 4
    self.scroll = 0
    self.text_height = 0
    self.locked = true
    self.font = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 10)
end

return BattleLog

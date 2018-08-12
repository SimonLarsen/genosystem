local DescriptionBoxSystem = class("systems.battle.DescriptionBoxSystem", System) 

function DescriptionBoxSystem:initialize()
    System.initialize(self)

    prox.events:addListener("events.DescriptionBoxEvent", self, self.onEvent)
end

function DescriptionBoxSystem:requires()
    return {"components.battle.DescriptionBox"}
end

function DescriptionBoxSystem:draw()
    for _, e in pairs(self.targets) do
        local box = e:get("components.battle.DescriptionBox")

        if box.type == "card" then
            local text_font = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 10)
            local title_font = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 13)
            local card = box.card_index[box.id]
            local img_bg = prox.resources.getImage("data/images/description_box.png")

            prox.gui.ImageButton(img_bg, prox.window.getWidth()/2-100, prox.window.getHeight()/2-65)
            prox.gui.Label(card.name, {font=title_font, "center"}, prox.window.getWidth()/2-90, prox.window.getHeight()/2-55, 180, 20)
            prox.gui.Label(card:getText(), {font=text_font, "center"}, prox.window.getWidth()/2-90, prox.window.getHeight()/2-30, 180, 90)

        elseif box.type == "gear" then
            local text_font = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 10)
            local title_font = prox.resources.getFont("data/fonts/FiraSans-Medium.ttf", 13)
            local gear = box.gear_index[box.id]
            local img_bg = prox.resources.getImage("data/images/description_box.png")

            prox.gui.ImageButton(img_bg, prox.window.getWidth()/2-100, prox.window.getHeight()/2-65)
            prox.gui.Label(gear.name, {font=title_font, "center"}, prox.window.getWidth()/2-90, prox.window.getHeight()/2-55, 180, 20)
            prox.gui.Label(gear:getText(), {font=text_font, "center"}, prox.window.getWidth()/2-90, prox.window.getHeight()/2-30, 180, 90)
        end
    end
end

function DescriptionBoxSystem:onEvent(event)
    for _, e in pairs(self.targets) do
        local box = e:get("components.battle.DescriptionBox")

        if event.enter then
            box.id = event.id
            box.type = event.type
            box.source = event.source
        else
            if event.source == box.source then
                box.id = nil
                box.type = nil
                box.source = nil
            end
        end
    end
end

return DescriptionBoxSystem

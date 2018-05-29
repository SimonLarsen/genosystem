local RandomAI = class("ai.RandomAI")

function RandomAI:initialize()
end

function RandomAI:play(player, opponent)
    return love.math.random(1, #player.hand)
end

function RandomAI:react(player, opponent, damage)
    if love.math.random() < 0.5 then
        return nil
    else
        local options = {}
        for i,v in ipairs(player.hand) do
            if v.block ~= nil then
                table.insert(options, i)
            end
        end
        assert(#options > 0, "Asked for reactive card, but no options available.")
        return options[love.math.random(#options)]
    end
end

return RandomAI

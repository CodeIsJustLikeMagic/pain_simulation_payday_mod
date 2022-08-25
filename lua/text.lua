VisualEffect = {}
VisualEffect.__index = VisualEffect

function VisualEffect:new(names, duration, paths, color, layer)
    local visef = {}
    setmetatable(visef, VisualEffect)
    visef.hudnames = names -- list of hudeffekt names
    visef.duration = duration
    visef.paths = paths -- create a hud for each path
    visef.color = color
    visef.layer = layer

    for i = 1, #visef.hudnames do
        print(visef.hudnames[i])
    end

    return visef
end

function VisualEffect:getRandomHud()
    return self.hudnames[math.random(#self.hudnames)]
end

SoundEffect = {}
SoundEffect.__index = SoundEffect

function SoundEffect:new(paths)
    local sndef = {}
    setmetatable(sndef, SoundEffect)
    sndef.soundpaths = paths
    return sndef
end

function SoundEffect:getSoundPath()
    return Simulation.sound1_path[math.random(#Simulation.sound1_path)]
end

if not Simulation then
    _G.Simulation = {}
    Simulation.VisualEffects = {}
    Simulation.SoundEffect = {}
end

local names = {}

table.insert(names, "h")
table.insert(names, "hoi")

v = VisualEffect:new(names, 0.2,{"assets/guis/textures/leech_ampule_effect", "assets/guis/textures/hello_there"},"000000",2)
table.insert(Simulation.VisualEffects,v)




VisualEffect = {}
VisualEffect.__index = VisualEffect

function VisualEffect:new(name, duration, paths, color, layer, animate)
    local visef = {}
    setmetatable(visef, VisualEffect)
    visef.hudnames = { } -- list of hudeffekt names
    visef.duration = duration
    visef.timers = { }
    visef.paths = paths -- create a hud for each path
    visef.color = color
    visef.layer = layer

    if animate == Nil then
        log("visual effect "..name.." no animate")
        visef.animate = false
    else
        visef.animate = true

    end
    for i = 1, #visef.paths do
        local hudname = name.."texture"..i
        table.insert(visef.hudnames, hudname)
        --log("painsimulation hudcreation: " .. hudname)
        local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
        if not hud.panel:child(hudname) then
            local Pain_event_visual_effect_hud_panel = hud.panel:bitmap({
                name = hudname,
                visible = false,
                texture = visef.paths[i],
                layer = visef.layer,
                color = Color(visef.color),
                blend_mode = "disable",

                w = hud.panel:w(),
                h = hud.panel:h(),
                x = 0,
                y = 0
            })
        end
        table.insert(visef.timers, 0)
    end

    return visef
end

function VisualEffect:startEffekt()
    local texture_num = math.random(#self.timers)
    self.timers[texture_num] = self.duration
    log("painsimulation startEffekt of "..self.hudnames[texture_num])
end

function VisualEffect:update(hud)
    for i = 1, #self.timers do
        local panelname = self.hudnames[i]
        local effect_hud_panel = hud.panel:child(panelname)

        if self.timers[i] > 0 then
            --log("painsimulation set texture visible "..panelname)
            --log("painsimulation set visible delta time is"..TimerManager:main():delta_time())
            self.timers[i] = self.timers[i] - TimerManager:main():delta_time()
            effect_hud_panel:set_visible(true)
            if self.animate then
                local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
                effect_hud_panel:animate(hudinfo.flash_icon, 40)

            end
        elseif self.timers[i] <=0 then
            effect_hud_panel:stop()
            effect_hud_panel:set_visible(false)
        end
    end
end

function VisualEffect:setVisible(bool, hud)
    for i = 1, #self.hudnames do
        local panelname = self.hudnames[i]
        local effect_hud_panel = hud.panel:child(panelname)
        effect_hud_panel:set_visible(bool)

        if not bool then
            effect_hud_panel:stop()
            self.timers[i] = 0
        end
        if self.animate then
            local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
            effect_hud_panel:animate(hudinfo.flash_icon, 40)
        end
    end
end


SoundEffect = {}
SoundEffect.__index = SoundEffect

function SoundEffect:new(paths)
    local sndef = {}
    setmetatable(sndef, SoundEffect)
    sndef.soundpaths = {}
    for i=1, #paths do
        table.insert(sndef.soundpaths, Simulation._path .. paths[i])
    end
    return sndef
end

function SoundEffect:getSoundPath()
    return self.soundpaths[math.random(#self.soundpaths)]
end

if not Simulation then
    _G.Simulation = {}
    log("Creating Pain Simulation")
    Simulation._path = ModPath
    log("Path is ".. Simulation._path)

    --for shielded hit
    Simulation.VisualEffectsShielded = {}
    Simulation.SoundEffectsShielded = {}
    --painsimulation.sound_path = {painsimulation._path .. "assets/sounds/squelsh hit__.ogg", painsimulation._path .. "assets/sounds/blup.ogg"}

    --for unshielded hit
    Simulation.VisualEffectsUnshielded = {}
    Simulation.SoundEffectsUnshielded = {}

    --for downed
    Simulation.VisualEffectsDowned = {}
    Simulation.SoundEffectsDowned = {}

    --for tased
    Simulation.VisualEffectsTased = {}
    Simulation.SoundEffectsTased = {}

    -- for dodge
    Simulation.EnableImmersiveDodgeSounds = false

    -- disable original
    Simulation.DisableDefaultHitDirection = false
    Simulation.DisableDefaultSound = false

end

local function EmptyArrays()
    for k in pairs (Simulation.VisualEffectsShielded) do
        Simulation.VisualEffectsShielded [k] = nil
    end
    for k in pairs (Simulation.SoundEffectsShielded) do
        Simulation.SoundEffectsShielded [k] = nil
    end
    for k in pairs (Simulation.VisualEffectsUnshielded) do
        Simulation.VisualEffectsUnshielded[k] = nil
    end
    for k in pairs (Simulation.SoundEffectsUnshielded) do
        Simulation.SoundEffectsUnshielded[k] = nil
    end
    for k in pairs (Simulation.VisualEffectsTased) do
        Simulation.VisualEffectsTased [k] = nil
    end
    for k in pairs (Simulation.SoundEffectsTased) do
        Simulation.SoundEffectsTased [k] = nil
    end
    for k in pairs (Simulation.VisualEffectsDowned) do
        Simulation.VisualEffectsDowned [k] = nil
    end
    for k in pairs (Simulation.SoundEffectsDowned) do
        Simulation.SoundEffectsDowned [k] = nil
    end

end

function Simulation:LoadProfile()

    local profileFile = io.open(Simulation._path .. PainSimulationOptions:GetProfile(),"r")
    log("PainSimulation Loading Profile "..PainSimulationOptions:GetProfile())
    local profile
    if profileFile then

        EmptyArrays()

        profile = json.decode(profileFile:read("*all"))
        profileFile:close()

        local EventVisualEffects = { Simulation.VisualEffectsShielded, Simulation.VisualEffectsUnshielded, Simulation.VisualEffectsDowned, Simulation.VisualEffectsTased}
        local EventSoundEffects = { Simulation.SoundEffectsShielded, Simulation.SoundEffectsUnshielded, Simulation.SoundEffectsDowned, Simulation.SoundEffectsTased}
        local eventprofile = {profile.shielded, profile.unshielded,profile.downed, profile.tased}

        for event = 1, #eventprofile do

            log("painsimulation loading event " .. event)
            local visuals = eventprofile[event].visuals
            log("painsimulation length of visuals: " .. #visuals)
            for i=1, #visuals do
                local effectdata = visuals[i]
                local v = VisualEffect:new("p"..PainSimulationOptions:GetProfileIndex()..
                        "hudevent"..event.."vis"..i,
                        effectdata.duration, effectdata.paths, effectdata.color, effectdata.layer, effectdata.animate)
                table.insert(EventVisualEffects[event],v)
            end
            local sounds = eventprofile[event].sounds
            log("painsimulation length of sounds: " .. #sounds)
            for i=1, #sounds do
                local s = SoundEffect:new(sounds[i].paths)
                table.insert(EventSoundEffects[event],s)
            end
        end
        log("PainSimulation disable hit direction is "..profile.disabledefaulthitdirection)
        if profile.disabledefaultsound == "false" then
            Simulation.DisableDefaultSound = false
        else
            Simulation.DisableDefaultSound = true
        end

        if profile.disabledefaulthitdirection == "false" then
            Simulation.DisableDefaultHitDirection = false
            log("PainSimulation should show hit direction")
        else
            Simulation.DisableDefaultHitDirection = true
        end

        if profile.immersivedodgesounds == "true" then
            Simulation.EnableImmersiveDodgeSounds = true
        else
            Simulation.EnableImmersiveDodgeSounds = false
        end
        log("painsimulation visual in total: "..#Simulation.VisualEffectsShielded)
    end
end

if blt.xaudio then
    blt.xaudio.setup()
    log("painsimulation setup xAudio")
end

-- load texture files so game can find them later
for _, file in pairs(file.GetFiles(Simulation._path.. "assets/guis/textures/")) do
    DB:create_entry(Idstring("texture"), Idstring("assets/guis/textures/".. file:gsub(".texture", "")), Simulation._path.. "assets/guis/textures/".. file)
end
--log("painsimulation successfully loaded texture files")



Hooks:PostHook(PlayerDamage, "init", "init_pain_event", function(self)
    --log("painsimulation playerdamage init")

    --read profile json and run SetUpHudTexture for each texture read.
    Simulation:LoadProfile()
    -- prepare hud element with the texture. hud made visble when player takes damage

    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
    managers.player:register_message(Message.OnPlayerDodge, "onDodge_pain_event", function()
        --XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path)):set_volume(1)
    end)

    Evaluation:levelLoad()
    Haptic:levelLoad()

    -- runs at level load
end)
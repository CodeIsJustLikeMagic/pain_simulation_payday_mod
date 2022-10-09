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
        --log("visual effect "..name.." no animate")
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
    --log("painsimulation startEffekt of "..self.hudnames[texture_num])
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
    --log("Creating Pain Simulation")
    Simulation._path = ModPath
    --log("Path is ".. Simulation._path)

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
    Simulation.IsCurrentlyBeingTased = false

    -- for dodge
    Simulation.EnableImmersiveDodgeSounds = false

    -- disable original
    Simulation.DisableDefaultHitDirection = false
    Simulation.DisableDefaultSound = false
    Simulation.DisableScreenFlashes = false

    Simulation.HeistRunning = false
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

function Simulation:StopFeedback()
    -- immediately stop all visuals.
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    for i=1, #Simulation.VisualEffectsDowned do
        Simulation.VisualEffectsDowned[i]:setVisible(false,hud)
    end
    for i=1, #Simulation.VisualEffectsTased do
        Simulation.VisualEffectsTased[i]:setVisible(false,hud)
    end
    for i=1, #Simulation.VisualEffectsUnshielded do
        Simulation.VisualEffectsUnshielded[i]:setVisible(false,hud)
    end
    for i=1, #Simulation.VisualEffectsShielded do
        Simulation.VisualEffectsShielded[i]:setVisible(false,hud)
    end
    Haptic:stop_feedback()
end

function Simulation:LoadProfile()
    if managers.hud == nil then
        return -- we are in main menu. Dont load when not in heist.
    end
    local profileFile = io.open(Simulation._path .. PainSimulationOptions:GetProfile(),"r")
    log("PainSimulation Loading Profile "..PainSimulationOptions:GetProfile())
    if Simulation.HeistRunning then
        Evaluation:saveEvalFile()
        -- dont save if we were previously in main menu. Only save if we switch profile mid heist
    end
    Evaluation:loadProfile()
    Haptic:loadProfile()
    Simulation.HeistRunning = true

    local profile
    if profileFile then
        Simulation:StopFeedback() -- stop any visuals and haptic that might be running before we loose references to them.
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
            --log("PainSimulation should show hit direction")
        else
            Simulation.DisableDefaultHitDirection = true
        end

        if profile.disablescreenflashes == "true" then
            Simulation.DisableScreenFlashes = true
            --log("PainSimulation should suppress screen flashes")
        else
            Simulation.DisableScreenFlashes = false
        end

        if profile.immersivedodgesounds == "true" then
            Simulation.EnableImmersiveDodgeSounds = true
        else
            Simulation.EnableImmersiveDodgeSounds = false
        end
    end
end

if blt.xaudio then
    blt.xaudio.setup()
    log("painsimulation setup xAudio")
end

-- load texture files so game can find them later. Unknown / unloaded texture will show up as a checkerboard pattern with 4 tiles
for _, file in pairs(file.GetFiles(Simulation._path.. "assets/guis/textures/")) do
    DB:create_entry(Idstring("texture"), Idstring("assets/guis/textures/".. file:gsub(".texture", "")), Simulation._path.. "assets/guis/textures/".. file)
end
--log("painsimulation successfully loaded texture files")

-- hapticMessages.lua doesn't have any hooks so it doest get called by the BLTbasemod.
-- so I have to load and run in myself
if Haptic == nil then
    dofile(PainSimulationOptions.modpath.."lua/hapticMessages.lua")
end


Hooks:PostHook(PlayerDamage, "init", "init_pain_event", function(self)
    --read profile json and set up huds for visuals as well as learn which sounds to play
    Simulation:LoadProfile()
    -- runs at level load
end)
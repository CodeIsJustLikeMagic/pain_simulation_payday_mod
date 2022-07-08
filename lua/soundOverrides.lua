VisualEffect = {}
VisualEffect.__index = VisualEffect

function VisualEffect:new(names, duration, paths, color, layer)
    local visef = {}
    setmetatable(visef, VisualEffect)
    visef.hudnames = names -- list of hudeffekt names
    visef.duration = duration
    visef.timers = { }
    visef.paths = paths -- create a hud for each path
    visef.color = color
    visef.layer = layer

    for i = 1, #visef.hudnames do
        local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
        if not hud.panel:child(visef.hudnames[i]) then
            local Pain_event_visual_effect_hud_panel = hud.panel:bitmap({
                name = visef.hudnames[i],
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
    self.timers[math.random(#self.timers)] = self.duration
end

SoundEffect = {}
SoundEffect.__index = SoundEffect

function SoundEffect:new(paths)
    local sndef = {}
    setmetatable(sndef, SoundEffect)
    sndef.soundpaths = {}
    for i=1, #paths do
        table.insert(sndef.soundpaths, PainEvent._path .. paths[i])
    end
    return sndef
end

function SoundEffect:getSoundPath()
    return self.soundpaths[math.random(#self.soundpaths)]
end

if not PainEvent then
    _G.PainEvent = {}
    PainEvent._path = ModPath

    --for shielded hit
    PainEvent.VisualEffectsShielded = {}
    PainEvent.SoundEffectShielded = {}
    --PainEvent.sound_path = {PainEvent._path .. "assets/sounds/squelsh hit__.ogg", PainEvent._path .. "assets/sounds/blup.ogg"}

    --for unshielded hit

    --for downed
end

local function LoadProfile()
    --load profile from a json file

    local profileFile = io.open(PainEvent._path .. "Profile1.json","r")
    local profile
    if profileFile then
        profileFile:close()

        local visuals = profile.shield.visuals
        log("painevent length of visuals: " .. #visuals)
        for i=1, #visuals do
            local effectdata = visuals[i]
            local v = VisualEffect:new(effectdata.names, effectdata.duration, effectdata.paths, effectdata.color, effectdata.layer)
            table.insert(PainEvent.VisualEffectsShielded,v)
        end
        local sounds = profile.shield.sounds
        for i=1, #sounds do
            local s = SoundEffect:new(sounds[i].paths)
            table.insert(PainEvent.SoundEffectShielded,s)
        end
    end

    --load unshielded

    --load downed
end

if blt.xaudio then
    blt.xaudio.setup()
    log("painevent setup xAudio")
end

-- load texture files so game can find them later
for _, file in pairs(file.GetFiles(PainEvent._path.. "assets/guis/textures/")) do
    DB:create_entry(Idstring("texture"), Idstring("assets/guis/textures/".. file:gsub(".texture", "")), PainEvent._path.. "assets/guis/textures/".. file)
end
log("painevent successfully loaded texture files")



Hooks:PostHook(PlayerDamage, "init", "init_pain_event", function(self)
    log("painevent playerdamage init")

    --read profile json and run SetUpHudTexture for each texture read.
    LoadProfile()
    -- prepare hud element with the texture. hud made visble when player takes damage

    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
    managers.player:register_message(Message.OnPlayerDodge, "onDodge_pain_event", function()
        --XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path)):set_volume(1)
    end)

    managers.player:unregister_message(Message.OnPlayerDamage, "onDamage_pain_event")
    managers.player:register_message(Message.OnPlayerDamage, "onDamage_pain_event", function()
        log("painevent running on player damage registered message")

        for i=1, #PainEvent.VisualEffectsShielded do
            PainEvent.VisualEffectsShielded[i]:startEffekt()
        end

        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(PainEvent.SoundEffectShielded[1]:getSoundPath())):set_volume(1)

    end)

end)

local function Effect_update(t, dt)

    --for every hud update timer and make invisible if their duration ran out
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    for j = 1, #PainEvent.VisualEffectsShielded do
        local visef = PainEvent.VisualEffectsShielded[j]

        for i = 1, #visef.timers do
            local panelname = visef.hudnames[i]
            local effect_hud_panel = hud.panel:child(panelname)

            if visef.timers[i] > 0 then
                log("painevent set visible delta time is"..TimerManager:main():delta_time())
                visef.timers[i] = visef.timers[i] - TimerManager:main():delta_time()
                effect_hud_panel:set_visible(true)
                local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
                effect_hud_panel:animate(hudinfo.flash_icon, 4000000000)
            elseif visef.timers[i] <=0 then
                effect_hud_panel:stop()
                effect_hud_panel:set_visible(false)
            end
        end
    end

end

Hooks:PreHook(PlayerDamage, "pre_destroy", "pre_destory_pain_event", function(self)
    log("painevent playerdamage pre destroy")
    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
end)

if string.lower(RequiredScript) == "lib/managers/hudmanager" then
    Hooks:PostHook(HUDManager, "update", "update_pain_event", function(self, t, dt)
        Effect_update(t, dt)
    end)
end
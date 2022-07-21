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
    PainEvent.SoundEffectsShielded = {}
    --PainEvent.sound_path = {PainEvent._path .. "assets/sounds/squelsh hit__.ogg", PainEvent._path .. "assets/sounds/blup.ogg"}

    --for unshielded hit
    PainEvent.VisualEffectsUnshielded = {}
    PainEvent.SoundEffectsUnshielded = {}

    --for downed
    PainEvent.VisualEffectsDowned = {}
    PainEvent.SoundEffectsDowned = {}

    --
    PainEvent.DisableDefaultHitDirection = true
    PainEvent.DisableDefaultSound = true
end

local function LoadProfile()

    local profileFile = io.open(PainEvent._path .. "Profile0.json","r")
    local profile
    if profileFile then

        profile = json.decode(profileFile:read("*all"))
        profileFile:close()

        local EventVisualEffects = {PainEvent.VisualEffectsShielded, PainEvent.VisualEffectsUnshielded, PainEvent.VisualEffectsDowned}
        local EventSoundEffects = {PainEvent.SoundEffectsShielded, PainEvent.SoundEffectsUnshielded, PainEvent.SoundEffectsDowned}
        local eventprofile = {profile.shielded, profile.unshielded,profile.downed}

        for event = 1, #eventprofile do

            log("painevent loading event " .. event)
            local visuals = eventprofile[event].visuals
            log("painevent length of visuals: " .. #visuals)
            for i=1, #visuals do
                local effectdata = visuals[i]
                local v = VisualEffect:new(effectdata.names, effectdata.duration, effectdata.paths, effectdata.color, effectdata.layer)
                table.insert(EventVisualEffects[event],v)
            end
            local sounds = eventprofile[event].sounds
            log("painevent length of visuals: " .. #sounds)
            for i=1, #sounds do
                local s = SoundEffect:new(sounds[i].paths)
                table.insert(EventSoundEffects[event],s)
            end
        end

        if profile.disabledefaultsound == "false" then
            PainEvent.DisableDefaultSound = false
        else
            PainEvent.DisableDefaultSound = true
        end

        if profile.disabledefaulthitdirection == "false" then
            PainEvent.DisableDefaultHitDirection = false
        else
            PainEvent.DisableDefaultHitDirection = true
        end

    end
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
        log("painevent Message.OnPlayer Damage. Player hp is "..MyPlayer.hp.." armor is "..MyPlayer.armor)
        if MyPlayer.armor <=0 then
            if MyPlayer.hp <=0 then
                PlayerHitRoutineDowned()
            else
                PlayerHitRoutineUnShielded()
            end
        else
            PlayerHitRoutineShielded()
        end
    end)

end)

local function RunRoutine(visualEffects, soundEffects)
    for i=1, #visualEffects do
        visualEffects[i]:startEffekt()
    end

    for i=1, #soundEffects do
        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(soundEffects[i]:getSoundPath())):set_volume(1)
    end
end

function PlayerHitRoutineShielded()
    log("painevent player hit routine shielded")
    RunRoutine(PainEvent.VisualEffectsShielded, PainEvent.SoundEffectsShielded)
    dohttpreq("http://localhost:8001/event/damage_shielded/", function(data2)
        --log("painevent damage_taken ".. data2)
    end)
end

function PlayerHitRoutineUnShielded()
    log("painevent player hit routine unshielded")
    RunRoutine(PainEvent.VisualEffectsUnshielded, PainEvent.SoundEffectsUnshielded)
    dohttpreq("http://localhost:8001/event/damage_unshielded/", function(data2)
        --log("painevent damage_taken ".. data2)
    end)
end

function PlayerHitRoutineDowned()
    log("painevent player hit routine downed")
    RunRoutine(PainEvent.VisualEffectsDowned, PainEvent.SoundEffectsDowned)
    dohttpreq("http://localhost:8001/event/damage_downed/", function(data2)
        --log("painevent damage_taken ".. data2)
    end)
end

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

--replace whole function. needs required script so PlayerSound isnt a nil value
if string.lower(RequiredScript) == "lib/units/beings/player/playersound" then
    function PlayerSound:play(sound_name, source_name, sync)
        log("painevent playersound "..sound_name)

        --disable hit sounds
        if PainEvent.DisableDefaultSound then
            if sound_name == "player_hit" or sound_name == "player_hit_permadamage" or sound_name == "player_armor_gone_stinger" then
                return
            end
        end
        local event_id = nil

        if type(sound_name) == "number" then
            event_id = sound_name
            sound_name = nil
        end

        if sync then
            event_id = event_id or SoundDevice:string_to_id(sound_name)
            source_name = source_name or ""

            self._unit:network():send("unit_sound_play", event_id, source_name)
        end

        local event = self:_play(sound_name or event_id, source_name)

        return event

    end
end

if string.lower(RequiredScript) == "lib/managers/hud/hudhitdirection" then
    function HUDHitDirection:_get_indicator_texture(damage_type)
        -- disable default hit direction arrow
        if PainEvent.DisableDefaultHitDirection then
            return "assets/guis/textures/nothing"
        end
        if managers.user:get_setting("color_blind_hit_direction") then
            if damage_type == HUDHitDirection.DAMAGE_TYPES.HEALTH then
                return "guis/textures/pd2/hitdirection_bold"
            elseif damage_type == HUDHitDirection.DAMAGE_TYPES.ARMOUR then
                return "guis/textures/pd2/hitdirection"
            end
        end

        return "guis/textures/pd2/hitdirection"
    end

end
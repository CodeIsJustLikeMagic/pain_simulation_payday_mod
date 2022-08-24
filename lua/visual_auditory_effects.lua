VisualEffect = {}
VisualEffect.__index = VisualEffect

function VisualEffect:new(name, duration, paths, color, layer)
    local visef = {}
    setmetatable(visef, VisualEffect)
    visef.hudnames = { } -- list of hudeffekt names
    visef.duration = duration
    visef.timers = { }
    visef.paths = paths -- create a hud for each path
    visef.color = color
    visef.layer = layer

    for i = 1, #visef.paths do
        local hudname = name.."texture"..i
        table.insert(visef.hudnames, hudname)
        --log("painevent hudcreation: " .. hudname)
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
    log("painevent startEffekt of "..self.hudnames[texture_num])
end

function VisualEffect:update(hud)
    for i = 1, #self.timers do
        local panelname = self.hudnames[i]
        local effect_hud_panel = hud.panel:child(panelname)

        if self.timers[i] > 0 then
            --log("painevent set texture visible "..panelname)
            --log("painevent set visible delta time is"..TimerManager:main():delta_time())
            self.timers[i] = self.timers[i] - TimerManager:main():delta_time()
            effect_hud_panel:set_visible(true)

            --local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
            --effect_hud_panel:animate(hudinfo.flash_icon, 4000000000)
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

        if bool then
            --log("painevent set "..panelname.." visible")
            --local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
            --effect_hud_panel:animate(hudinfo.flash_icon, 4000000000)
        else
            effect_hud_panel:stop()
            self.timers[i] = 0
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

    Leech_Ampule_Effect._settings_path = ModPath .. "menu/settings.txt"
    Leech_Ampule_Effect._menu_path = ModPath .. "menu/menu.txt"

end

local function LoadProfile()

    local profileFile = io.open(PainEvent._path .. PainSimulationOptions:GetProfile(),"r")
    log("PainSimulation Loading Profile "..PainSimulationOptions:GetProfile())
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
                local v = VisualEffect:new("hudevent"..event.."vis"..i, effectdata.duration, effectdata.paths, effectdata.color, effectdata.layer)
                table.insert(EventVisualEffects[event],v)
            end
            local sounds = eventprofile[event].sounds
            log("painevent length of visuals: " .. #sounds)
            for i=1, #sounds do
                local s = SoundEffect:new(sounds[i].paths)
                table.insert(EventSoundEffects[event],s)
            end
        end
        log("PainSimulation disable hit direction is "..profile.disabledefaulthitdirection)
        if profile.disabledefaultsound == "false" then
            PainEvent.DisableDefaultSound = false
        else
            PainEvent.DisableDefaultSound = true
        end

        if profile.disabledefaulthitdirection == "false" then
            PainEvent.DisableDefaultHitDirection = false
            log("PainSimulation should show hit direction")
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
--log("painevent successfully loaded texture files")



Hooks:PostHook(PlayerDamage, "init", "init_pain_event", function(self)
    --log("painevent playerdamage init")

    --read profile json and run SetUpHudTexture for each texture read.
    LoadProfile()
    -- prepare hud element with the texture. hud made visble when player takes damage

    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
    managers.player:register_message(Message.OnPlayerDodge, "onDodge_pain_event", function()
        --XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path)):set_volume(1)
    end)

    Evaluation:levelLoad()
    -- runs at level load
end)

Hooks:PostHook(PlayerDamage, "on_downed","on_downed_pain_event", function(self)
    PlayerHitRoutineDowned()
    Evaluation:hpAndArmor()
    -- runs when player is downed (0 hp and 0 armor)
end)

Hooks:PostHook(PlayerDamage, "revive", "revive_pain_event", function(self, silent)
    PlayerReviveRoutine()
    log("painevent player revived by ally")
    Evaluation:hpAndArmor()
    -- runs when player is helped after being downed
end)

Hooks:PostHook(PlayerDamage, "_regenerate_armor", "_regenerate_armor_pain_event", function(self, no_sound)
    log("_regenerate_armor")
    Evaluation:regenerateArmor()

    -- armor regenerating itself after not being attacked for a few seconds
end)

local function RunRoutine(visualEffects, soundEffects)

    for i=1, #visualEffects do
        --log("painevent startEffect "..i)
        visualEffects[i]:startEffekt()
    end

    for i=1, #soundEffects do
        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(soundEffects[i]:getSoundPath())):set_volume(1)
    end
end

function PlayerHitRoutineShielded(rotation)
    log("painevent player hit routine shielded ")
    RunRoutine(PainEvent.VisualEffectsShielded, PainEvent.SoundEffectsShielded)
    Evaluation:shieldedHit()

    dohttpreq("http://localhost:8001/event/damage_taken_shielded/"..rotation, function(data2)
    end)
end

function PlayerHitRoutineUnShielded(rotation)
    log("painevent player hit routine unshielded ")
    RunRoutine(PainEvent.VisualEffectsUnshielded, PainEvent.SoundEffectsUnshielded)
    Evaluation:unshieldedHit()

    dohttpreq("http://localhost:8001/event/damage_taken_unshielded/"..rotation, function(data2)
    end)
end

function PlayerHitRoutineDowned()
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    log("painevent player hit routine downed")
    for i=1, #PainEvent.VisualEffectsDowned do
        PainEvent.VisualEffectsDowned[i]:setVisible(true,hud)
    end
    for i=1, #PainEvent.VisualEffectsUnshielded do
        PainEvent.VisualEffectsUnshielded[i]:setVisible(false,hud)
    end
    for i=1, #PainEvent.VisualEffectsShielded do
        PainEvent.VisualEffectsShielded[i]:setVisible(false,hud)
    end
    Evaluation:downed()

    dohttpreq("http://localhost:8001/event/downed", function(data2)
    end)
end

function PlayerReviveRoutine()
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    for i=1, #PainEvent.VisualEffectsDowned do
        PainEvent.VisualEffectsDowned[i]:setVisible(false,hud)
    end
    Evaluation:revived()

    dohttpreq("http://localhost:8001/event/revived", function(data2)
    end)

end

local function Effect_update(t, dt)

    --for every hud update timer and make invisible if their duration ran out
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    for j = 1, #PainEvent.VisualEffectsShielded do
        PainEvent.VisualEffectsShielded[j]:update(hud)
    end
    for j = 1, #PainEvent.VisualEffectsUnshielded do
        PainEvent.VisualEffectsUnshielded[j]:update(hud)
    end
end

Hooks:PreHook(PlayerDamage, "pre_destroy", "pre_destory_pain_event", function(self)
    Evaluation:levelQuit()
    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
    -- runs just before level is quit
end)

if string.lower(RequiredScript) == "lib/managers/hudmanager" then
    Hooks:PostHook(HUDManager, "update", "update_pain_event", function(self, t, dt)
        Effect_update(t, dt)
    end)
    -- runs on every game update
end

--replace whole function. needs required script so PlayerSound isnt a nil value
if string.lower(RequiredScript) == "lib/units/beings/player/playersound" then
    function PlayerSound:play(sound_name, source_name, sync)
        --log("painevent playersound "..sound_name)

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
    -- runs when sound is played for player
end

Hooks:PostHook(PlayerDamage, "on_tased", "on_tased_pain_event", function(self, non_lethal)
    log("painevent on_tased")
    dohttpreq("http://localhost:8001/event/tased", function(data2)
    end)
    Evaluation:hpAndArmor()
    Evaluation:tased()
end)

Hooks:PostHook(HUDHitDirection, "_add_hit_indicator", "_add_hit_indicator_pain_event", function(self, damage_origin, damage_type, fixed_angle)
    Evaluation:hpAndArmor()
    log("painevent add hit indicator. run FeedbackRoutines")
    --run our visual effects
    log("damage origin: "..damage_origin)
    log("damage_type: "..damage_type)

    -- figure out rotation

    local rotation = 0
    if managers.player:player_unit() then
        local ply_camera = managers.player:player_unit():camera()
        if ply_camera then
            local target_vec = ply_camera:position() - damage_origin
            local angle = target_vec:to_polar_with_reference(ply_camera:forward(), math.UP).spin
            if fixed_angle ~= nil then
                angle = fixed_angle
            end
            -- rotation that is used for viusal direction indicators at the middle of the screen
            rotation = 90 - angle

            -- change rotation to fit bhaptics :)
            rotation = 180 - rotation + 90
        end
    end
    log("rotation is "..rotation)

    if damage_type == HUDHitDirection.DAMAGE_TYPES.HEALTH then
    log("painevent run hit routine unshielded")
    PlayerHitRoutineUnShielded(rotation)
    else if damage_type == HUDHitDirection.DAMAGE_TYPES.ARMOUR then
    log("painevent run hit routine shielded")
    PlayerHitRoutineShielded(rotation)
    end
    end
    end)

if string.lower(RequiredScript) == "lib/managers/hud/hudhitdirection" then
    function HUDHitDirection:_get_indicator_texture(damage_type)
        log("painevent get indicator texture upon getting hit")
        -- disable default hit direction arrow
        if PainEvent.DisableDefaultHitDirection then
            log("PainSimulation hiding default hit direction")
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
    -- runs when player gets damaged
end
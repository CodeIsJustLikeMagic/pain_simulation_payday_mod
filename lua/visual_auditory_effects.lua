local function RunRoutine(visualEffects, soundEffects)

    for i=1, #visualEffects do
        --log("painsimulation startEffect "..i)
        visualEffects[i]:startEffekt()
    end

    for i=1, #soundEffects do
        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(soundEffects[i]:getSoundPath())):set_volume(1)
    end
end

function PlayerHitRoutineShielded(rotation)
    log("painsimulation player hit routine shielded ")
    RunRoutine(Simulation.VisualEffectsShielded, Simulation.SoundEffectsShielded)
    Evaluation:shieldedHit()
    Haptic:damageTakenShielded(rotation)

end

function PlayerHitRoutineUnShielded(rotation)
    log("painsimulation player hit routine unshielded ")
    RunRoutine(Simulation.VisualEffectsUnshielded, Simulation.SoundEffectsUnshielded)
    Evaluation:unshieldedHit()
    Haptic:damageTakenUnshielded(rotation)
end

function PlayerHitRoutineDowned()
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    log("painsimulation player hit routine downed")
    for i=1, #Simulation.VisualEffectsDowned do
        Simulation.VisualEffectsDowned[i]:setVisible(true,hud)
    end
    for i=1, #Simulation.VisualEffectsUnshielded do
        Simulation.VisualEffectsUnshielded[i]:setVisible(false,hud)
    end
    for i=1, #Simulation.VisualEffectsShielded do
        Simulation.VisualEffectsShielded[i]:setVisible(false,hud)
    end
    Evaluation:downed()
    Haptic:downed()

end

function PlayerTasedRoutine()
    local hud = manager.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    log("painsimulation player tased routine")
    for i = 1, #Simulation.VisualEffectsTased do
        Simulation.VisualEffectsTased[i]:setVisible(true,hud)
    end
    Haptic:tased()
end

function PlayerStopTasedRoutine()
    local hud = manager.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    log("painsimulation player tased routine")
    for i = 1, #Simulation.VisualEffectsTased do
        Simulation.VisualEffectsTased[i]:setVisible(false,hud)
    end
    Haptic:tased()
end

function PlayerReviveRoutine()
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    for i=1, #Simulation.VisualEffectsDowned do
        Simulation.VisualEffectsDowned[i]:setVisible(false,hud)
    end
    Haptic:revived()
end

Hooks:PostHook(PlayerDamage, "on_downed","on_downed_pain_event", function(self)
    PlayerHitRoutineDowned()
    Evaluation:hpAndArmor()
    -- runs when player is downed (0 hp and 0 armor)
end)

Hooks:PostHook(PlayerDamage, "revive", "revive_pain_event", function(self, silent)
    PlayerReviveRoutine()
    log("painsimulation player revived by ally")
    Evaluation:hpAndArmor()
    Evaluation:revived()
    -- runs when player is helped after being downed
end)

Hooks:PostHook(PlayerDamage, "_regenerate_armor", "_regenerate_armor_pain_event", function(self, no_sound)
    log("_regenerate_armor")
    Evaluation:regenerateArmor()

    -- armor regenerating itself after not being attacked for a few seconds
end)

Hooks:PostHook(PlayerDamage, "on_tased", "on_tased_pain_event", function(self, non_lethal)
    PlayerTasedRoutine()
    Evaluation:hpAndArmor()
    Evaluation:tased()
end)

Hooks:PostHook(PlayerDamage, "erase_tase_data", "erase_tase_data_pain_event", function(self, non_lethal)
    log("painsimulation erase_tased_data")
    Haptic:taseStop()
end)

Hooks:PostHook(HUDHitDirection, "_add_hit_indicator", "_add_hit_indicator_pain_event", function(self, damage_origin, damage_type, fixed_angle)
    Evaluation:hpAndArmor()
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
    log("painsimulation run hit routine unshielded")
    PlayerHitRoutineUnShielded(rotation)
    else if damage_type == HUDHitDirection.DAMAGE_TYPES.ARMOUR then
    log("painsimulation run hit routine shielded")
    PlayerHitRoutineShielded(rotation)
    end
    end
end)

local function Effect_update(t, dt)

    --for every hud update timer and make invisible if their duration ran out
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    for j = 1, #Simulation.VisualEffectsShielded do
        Simulation.VisualEffectsShielded[j]:update(hud)
    end
    for j = 1, #Simulation.VisualEffectsUnshielded do
        Simulation.VisualEffectsUnshielded[j]:update(hud)
    end
end

if string.lower(RequiredScript) == "lib/managers/hudmanager" then
    Hooks:PostHook(HUDManager, "update", "update_pain_event", function(self, t, dt)
        Effect_update(t, dt)
    end)
    -- runs on every game update
end

Hooks:PreHook(PlayerDamage, "pre_destroy", "pre_destory_pain_event", function(self)
    Evaluation:levelQuit()
    Haptic:levelQuit()
    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
    -- runs just before level is quit
end)
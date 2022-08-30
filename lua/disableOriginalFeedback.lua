
-- disable hit sounds
-- replace whole function. needs required script so PlayerSound isnt a nil value
if string.lower(RequiredScript) == "lib/units/beings/player/playersound" then
    function PlayerSound:play(sound_name, source_name, sync)
        --log("painsimulation playersound "..sound_name)

        --disable hit sounds
        if Simulation.DisableDefaultSound then
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

-- disable default hit direction arrow, by replacing with blank texture
if string.lower(RequiredScript) == "lib/managers/hud/hudhitdirection" then
    function HUDHitDirection:_get_indicator_texture(damage_type)
        log("painsimulation get indicator texture upon getting hit")
        if Simulation.DisableDefaultHitDirection then
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

Hooks:PostHook(HUDPlayerCustody, "init", "init_pain_event", function(self, data, ...)
    dohttpreq("http://localhost:8001/event/level_load/", function(data2)
        log("painevent answer ".. data2)
    end)
    blt.xaudio.setup()
    log("painevent xaduio setup run")
end)

Hooks:PostHook(HUDTeammate, "set_armor", "set_armor_pain_event", function(self, data, ...)
    local Value = math.clamp(data.current / data.total, 0, 1)
    local real_value = math.round((data.total * 10) * Value)
    dohttpreq("http://localhost:8001/event/shield/"..real_value, function(data2)
        log("painevent set_armor ".. data2)
    end)
    -- hitsounds play
    local source
    local snd_path = ModPath .. "assets/obi-wan-hello-there.ogg"
    local volume = 1
    log("painevent blaaaaaaaaaaaa xaduio before buffer creation filepath:" .. snd_path)
    log("painevent unint source: " .. XAudio.PLAYER)
    --source = XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path))
    source = XAudio.Source:new(XAudio.Buffer:new(snd_path))
    log("painevent xaduio succesfull source creation")
    if source then
        --source:set_volume(volume)
        log("set_volume done")
    end
    log("painevent hoi")
    --log("painevent done with audio source closed? " .. source:is_closed())

end)

Hooks:PostHook(HUDTeammate, "set_health", "set_health_pain_event", function(self, data, ...)
    local Value = math.clamp(data.current / data.total, 0, 1)
    local real_value = math.round((data.total * 10) * Value)
    dohttpreq("http://localhost:8001/event/health/"..real_value, function(data2)
        log("painevent set_health ".. data2)
    end)
end)

Hooks:PostHook(HUDTeammate, "_damage_taken", "damage_taken_pain_event", function(self, ...)
    dohttpreq("http://localhost:8001/event/damage_taken/", function(data2)
        log("painevent damage_taken ".. data2)
    end)
end)

Hooks:PostHook(HUDPlayerDowned, "on_downed", "on_downed_pain_event", function(self, ...)
    dohttpreq("http://localhost:8001/event/downed/", function(data2)
        log("painevent on_downed ".. data2)
    end)
end)

Hooks:PostHook(HUDPlayerDowned, "on_arrested", "on_arrested_pain_event", function(self, ...)
    dohttpreq("http://localhost:8001/event/arrested/", function(data2)
        log("painevent on_arrested ".. data2)
    end)
end)

Hooks:PostHook(HUDPlayerCustody, "set_respawn_time", "set_respawn_time_pain_event", function(self, time, ...)
    dohttpreq("http://localhost:8001/event/custody/", function(data2)
        log("painevent set_respawn_time ".. data2)
    end)
end)

Hooks:PostHook(PlayerManager, "on_killshot", "on_killshot_pain_event", function(self, killed_unit, variant, headshot, weapon_id, ...)
    local player_unit = self:player_unit()

    if not player_unit then
        return
    end

    if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
        return
    end

    dohttpreq("http://localhost:8001/evaluate/killshot/", function(data2)
        log("paineventanswer on_killshot ".. data2)
    end)
end)


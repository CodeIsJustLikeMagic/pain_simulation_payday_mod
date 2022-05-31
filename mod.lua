-- sound changes
local ThisModPath = ModPath
local snd_path = ThisModPath .. "assets/obi-wan-hello-there.ogg"

if not io.file_is_readable(snd_path)then
    log("painevent ERROR cannot find filepath " .. snd_path)
end
if blt.xaudio and io.file_is_readable(snd_path) then
    blt.xaudio.setup()
    log("painevent setup xAudio")
else
    return
    log("painevent ERROR stopping mod !!!")
end

Hooks:PostHook(HUDPlayerCustody, "init", "init_pain_event", function(self, data, ...)
    dohttpreq("http://localhost:8001/event/level_load/", function(data2)
        log("painevent answer ".. data2)
    end)
end)

Hooks:PostHook(PlayerDamage, "init", "init_pain_event", function(self)
    managers.player:unregister_message(Nessage.OnPlayerDodge, "bla_pain_event")
    managers.player:register_message(Message.OnPlayerDodge, "bla_pain_event", function()
        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path)):set_volume(1)
    end)
    log("painevent registered Message that plays sound on dodge")
end)

Hooks:PreHook(PlayerDamage, "pre_destroy", "pre_destory_pain_event", function(self)
    managers.player:unregister_message(Message.OnPlayerDodge, "bla_pain_event")
end)



-- events for haptic
Hooks:PostHook(HUDTeammate, "set_armor", "set_armor_pain_event", function(self, data, ...)
    local Value = math.clamp(data.current / data.total, 0, 1)
    local real_value = math.round((data.total * 10) * Value)
    dohttpreq("http://localhost:8001/event/shield/"..real_value, function(data2)
        log("painevent set_armor ".. data2)
    end)
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


-- evaluation data
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


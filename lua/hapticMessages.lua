-- events for haptic

if not MyPlayer then
    _G.MyPlayer = {}
    MyPlayer.hp = 0
    MyPlayer.armor = 0
end


Hooks:PostHook(HUDPlayerCustody, "init", "init_pain_event", function(self, data, ...)
    --dohttpreq("http://localhost:8001/event/level_load/", function(data2)
        --log("painevent loading level ".. data2)
    --end)
end)


Hooks:PostHook(HUDTeammate, "set_armor", "set_armor_pain_event", function(self, data, ...)
    local Value = math.clamp(data.current / data.total, 0, 1)
    local real_value = math.round((data.total * 10) * Value)
    --dohttpreq("http://localhost:8001/event/shield/"..real_value, function(data2)
        --log("painevent set_armor ".. data2)
    --end)
    --PlayerHitRoutineShielded()
    --log("painevent player armor set to "..real_value)
    MyPlayer.armor = real_value
end)

Hooks:PostHook(HUDTeammate, "set_health", "set_health_pain_event", function(self, data, ...)
    local Value = math.clamp(data.current / data.total, 0, 1)
    local real_value = math.round((data.total * 10) * Value)
    --dohttpreq("http://localhost:8001/event/health/"..real_value, function(data2)
        --log("painevent set_health ".. data2)
    --end)
    --PlayerHitRoutineShielded()
    --log("painevent player hp set to "..real_value)
    MyPlayer.hp = real_value
end)

Hooks:PostHook(HUDTeammate, "_damage_taken", "damage_taken_pain_event", function(self, ...)
    --dohttpreq("http://localhost:8001/event/damage_taken/", function(data2)
        --log("painevent damage_taken ".. data2)
    --end)
    --log("painevent hud teammate damage taken")
end)

Hooks:PostHook(HUDPlayerDowned, "on_downed", "on_downed_pain_event", function(self, ...)
    --dohttpreq("http://localhost:8001/event/downed/", function(data2)
        --log("painevent on_downed ".. data2)
    --end)
end)

Hooks:PostHook(HUDPlayerDowned, "on_arrested", "on_arrested_pain_event", function(self, ...)
    --dohttpreq("http://localhost:8001/event/arrested/", function(data2)
        --log("painevent on_arrested ".. data2)
    --end)
end)

Hooks:PostHook(HUDPlayerCustody, "set_respawn_time", "set_respawn_time_pain_event", function(self, time, ...)
    --dohttpreq("http://localhost:8001/event/custody/", function(data2)
        --log("painevent set_respawn_time ".. data2)
    --end)
end)


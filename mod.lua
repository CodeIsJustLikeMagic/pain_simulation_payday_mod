Hooks:PostHook(HUDPlayerCustody, "init", "init_pain_event", function(self, data, ...)
    dohttpreq("http://localhost:8001/event/level_load/", function(data2)
        log("answer ".. data2)
    end)
end)

Hooks:PostHook(HUDTeammate, "set_armor", "set_armor_pain_event", function(self, data, ...)
    local Value = math.clamp(data.current / data.total, 0, 1)
    local real_value = math.round((data.total * 10) * Value)
    dohttpreq("http://localhost:8001/event/shield/"..real_value, function(data2)
        log("answer ".. data2)
    end)
end)

Hooks:PostHook(HUDTeammate, "set_health", "set_health_pain_event", function(self, data, ...)
    local Value = math.clamp(data.current / data.total, 0, 1)
    local real_value = math.round((data.total * 10) * Value)
    dohttpreq("http://localhost:8001/event/health/"..real_value, function(data2)
        log("answer ".. data2)
    end)
end)

Hooks:PostHook(HUDTeammate, "_damage_taken", "damage_taken_pain_event", function(self, ...)
    dohttpreq("http://localhost:8001/event/damage_taken/", function(data2)
        log("answer ".. data2)
    end)
end)

Hooks:PostHook(HUDPlayerDowned, "on_downed", "on_downed_pain_event", function(self, ...)
    dohttpreq("http://localhost:8001/event/downed/", function(data2)
        log("answer ".. data2)
    end)
end)

Hooks:PostHook(HUDPlayerDowned, "on_arrested", "on_arrested_pain_event", function(self, ...)
    dohttpreq("http://localhost:8001/event/arrested/", function(data2)
        log("answer ".. data2)
    end)
end)

Hooks:PostHook(HUDPlayerCustody, "set_respawn_time", "set_respawn_time_pain_event", function(self, time, ...)
    dohttpreq("http://localhost:8001/event/custody/", function(data2)
        log("answer ".. data2)
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
        log("answer ".. data2)
    end)
end)



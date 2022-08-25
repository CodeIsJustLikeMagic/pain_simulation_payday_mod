-- events for haptic

if not MyPlayer then
    _G.MyPlayer = {}
    MyPlayer.hp = 0
    MyPlayer.armor = 0
end


Hooks:PostHook(HUDTeammate, "set_armor", "set_armor_pain_event", function(self, data, ...)
    local Value = math.clamp(data.current / data.total, 0, 1)
    local real_value = math.round((data.total * 10) * Value)
    MyPlayer.armor = real_value
end)

Hooks:PostHook(HUDTeammate, "set_health", "set_health_pain_event", function(self, data, ...)
    local Value = math.clamp(data.current / data.total, 0, 1)
    local real_value = math.round((data.total * 10) * Value)
    MyPlayer.hp = real_value
end)


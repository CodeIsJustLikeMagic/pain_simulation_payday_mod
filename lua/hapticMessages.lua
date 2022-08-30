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

-- messages to haptic server

if not Haptic then
    _G.Haptic = {}
end

function Haptic:levelLoad()
    dohttpreq("http://localhost:8001/event/levelload/"..PainSimulationOptions:GetProfile(), function(data2)
    end)
end

function Haptic:damageTakenShielded(rotation)
    dohttpreq("http://localhost:8001/event/damage_taken_shielded/"..rotation, function(data2)
    end)
end

function Haptic:damageTakenUnshielded(rotation)
    dohttpreq("http://localhost:8001/event/damage_taken_unshielded/"..rotation, function(data2)
    end)
end

function Haptic:downed()
    dohttpreq("http://localhost:8001/event/downed", function(data2)
    end)
end

function Haptic:revived()
    dohttpreq("http://localhost:8001/event/revived", function(data2)
    end)
end

function Haptic:levelQuit()
    dohttpreq("http://localhost:8001/event/levelquit", function(data2)
    end)
end

function Haptic:tased()
    dohttpreq("http://localhost:8001/event/tased", function(data2)
    end)
end

function Haptic:taseStop()
    dohttpreq("http://localhost:8001/event/tasestoped", function(data2)
    end)
end
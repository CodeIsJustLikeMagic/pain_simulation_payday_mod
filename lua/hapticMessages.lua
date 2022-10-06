-- messages to haptic server
if not Haptic then
    _G.Haptic = {}
end

log("hatpic Messages here :)")

function Haptic:loadProfile()
    dohttpreq("http://localhost:8001/event/load_profile/"..PainSimulationOptions:GetProfile(), function(data2)
    end)
end

function Haptic:damageTakenShielded(rotation)
    dohttpreq("http://localhost:8001/event/damage_taken_shielded/"..rotation, function(data2)
    end)
    -- run oneshot haptic feedback
end

function Haptic:damageTakenUnshielded(rotation)
    dohttpreq("http://localhost:8001/event/damage_taken_unshielded/"..rotation, function(data2)
    end)
    -- run oneshot haptic feedback
end

function Haptic:downed()
    dohttpreq("http://localhost:8001/event/downed", function(data2)
    end)
    -- start downed haptic loop
    -- if tased, tase effect will stop and downed will start
end

function Haptic:revived()
    dohttpreq("http://localhost:8001/event/revived", function(data2)
    end)
    -- stop downed haptic loop
end

function Haptic:tased()
    dohttpreq("http://localhost:8001/event/tased", function(data2)
    end)
    -- start tased haptic loop
    -- cannot be tased if alrady downed
end

function Haptic:taseStop()
    dohttpreq("http://localhost:8001/event/tasestoped", function(data2)
    end)
    -- stop tased haptic loop
end

function Haptic:stop_feedback()
    dohttpreq("http://localhost:8001/event/stop_feedback", function(data2)
    end)
    -- stops all current haptic feedback
end
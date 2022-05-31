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
-- evaluation data

if not Evaluation then
    _G.Evaluation = {}
    Evaluation.hp = 0
    Evaluation.armor = 0
end

if string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then
    Hooks:PostHook(HUDTeammate, "set_armor", "set_armor_pain_event", function(self, data, ...)
        local Value = math.clamp(data.current / data.total, 0, 1)
        local real_value = math.round((data.total * 10) * Value)
        Evaluation.armor = real_value
        -- this shouldnt run but it does
    end)

end

if string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then
    Hooks:PostHook(HUDTeammate, "set_health", "set_health_pain_event", function(self, data, ...)
        local Value = math.clamp(data.current / data.total, 0, 1)
        local real_value = math.round((data.total * 10) * Value)
        Evaluation.hp = real_value
    end)

end

if string.lower(RequiredScript) == "lib/managers/playermanager" then
    Hooks:PostHook(PlayerManager, "on_killshot", "on_killshot_pain_event", function(self, killed_unit, variant, headshot, weapon_id, ...)
        local player_unit = self:player_unit()

        if not player_unit then
            return
        end

        if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
            return
        end

        dohttpreq("http://localhost:8001/evaluate/killshot", function(data2)
        end)
        -- works
    end)

end

function Evaluation:unshieldedHit()
    dohttpreq("http://localhost:8001/evaluate/unshielded", function(data2)
    end)
end

function Evaluation:shieldedHit()
    dohttpreq("http://localhost:8001/evaluate/shielded", function(data2)
    end)
end

function Evaluation:downed()
    dohttpreq("http://localhost:8001/evaluate/downed", function(data2)
    end)
end

function Evaluation:revived()
    dohttpreq("http://localhost:8001/evaluate/revived", function(data2)
    end)
end

function Evaluation:loadProfile()
    dohttpreq("http://localhost:8001/evaluate/loadprofile/"..PainSimulationOptions:GetProfile().."?playertag=".. PainSimulationOptions:Playertag(), function(data2)
    end)
    -- evaluation server will make a new csv file.
end

function Evaluation:saveEvalFile()
    if managers.statistics:session_hit_accuracy() == nil then
        log("painevent no active game to get stats from or to save eval file for")
        return
    end
    log("painevent save Eval File")

    dohttpreq("http://localhost:8001/evaluate/saveevalfile", function(data2)
    end)
    return
    dohttpreq("http://localhost:8001/evaluate/saveevalfile/" .. managers.statistics:session_hit_accuracy() ..
            "?session_total_downed=" .. managers.statistics:total_downed() ..
            "&session_total_kills=" .. managers.statistics:session_total_kills() ..
            "&session_total_head_shots=" .. managers.statistics:session_total_head_shots() ..
            "&session_total_specials_kills=" .. managers.statistics:session_total_specials_kills() ..
            "&session_civilian_kills=" .. managers.statistics:session_total_civilian_kills() ..
    "", function(data2)
    end) -- sadly cannot get the session stats because it hangs the game
    -- plus session stats apply to the entire heist but profile can be changed mid heist.
    -- so I can't really use the session statistics at all.
end

function Evaluation:hpAndArmor()
    log("painevent Hp and Armor save")
    dohttpreq("http://localhost:8001/evaluate/sethp/"..Evaluation.hp.."?armor="..Evaluation.armor, function(data2)
    end)
    -- works
end

function Evaluation:regenerateArmor()
    dohttpreq("http://localhost:8001/evaluate/regeneratearmor", function(data2)
    end)
    -- works
end

function Evaluation:tased()
    dohttpreq("http://localhost:8001/evaluate/tased", function(data2)
    end)
    -- works
end

if string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
    Hooks:PostHook(PlayerDamage, "restore_health","restore_health_pain_event", function(self)
        log("painevent replenish")
        dohttpreq("http://localhost:8001/evaluate/restore_hp", function(data2)
        end)
        Evaluation:hpAndArmor()
        -- this runs after armor regenerateArmor a few times
        -- works
    end)

end

if string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
    Hooks:PostHook(PlayerDamage, "recover_health","recover_health_event", function(self)
        log("painevent doctor bag used")
        dohttpreq("http://localhost:8001/evaluate/doctor_bag_used", function(data2)
        end)
        Evaluation:hpAndArmor()
        -- runs when doctor bag is used
    end)

end

if string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
    Hooks:PostHook(PlayerDamage, "set_armor","set_armor_playerdamage_pain_event", function(self)
        log("painevent set_armor")

        Evaluation:hpAndArmor()
        -- runs anytime armor is set, armor goes up over a few calls
    end)

end

if string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
    Hooks:PostHook(PlayerDamage, "set_health","set_armor_playerdamage_pain_event", function(self)
        log("painevent set_armor")
        Evaluation:hpAndArmor()
        -- runs anytime hp is set
    end)

end

if string.lower(RequiredScript) == "lib/managers/hud/hudhitconfirmed" then
    Hooks:PostHook(HUDHitConfirm, "on_hit_confirmed","on_hit_confirmed_pain_event", function(self, damage_scale)
        log("painevent on hit confirmed")
        dohttpreq("http://localhost:8001/evaluate/enemy_hit", function(data2)
        end)
        -- works
    end)

end

-- thanks to https://modworkshop.net/mod/16984 by Schmuddel for finding which one
-- of the many many headshot functions is actually run
if string.lower(RequiredScript) == "lib/managers/playermanager" then
    Hooks:PostHook(PlayerManager, "on_headshot_dealt","on_headshot_dealt_pain_event", function(self)
        log("painevent PlayerManager on headshot dealt")
        dohttpreq("http://localhost:8001/evaluate/enemy_headshot", function(data2)
        end)
    end)
end

if string.lower(RequiredScript) == "lib/managers/hud/hudobjectives" then
    Hooks:PostHook(HUDObjectives, "complete_objective", "complete_objective_pain_event", function(self, data)
        log("painevent complete_objective" .. data.text)
        dohttpreq("http://localhost:8001/evaluate/complete_objective/" .. data.text:gsub(" ","_"), function(data2)
        end)
        -- runs wenn objective (game goal) is completed
    end)
end

if string.lower(RequiredScript) == "lib/managers/hud/hudobjectives" then
    Hooks:PostHook(HUDObjectives, "activate_objective", "activate_objective_pain_event", function(self, data)
        log("painevent activate_objective" .. data.text)
        dohttpreq("http://localhost:8001/evaluate/activate_objective/"..data.text:gsub(" ","_"), function(data2)
        end)
        -- runs when new in game objective (game goal) starts
    end)
end



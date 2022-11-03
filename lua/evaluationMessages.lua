-- evaluation data

if not Evaluation then
    _G.Evaluation = {}
    Evaluation.hp = 0
    Evaluation.armor = 0
end

if string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then
    Hooks:PostHook(HUDTeammate, "set_armor", "set_armor_pain_simulation", function(self, data, ...)
        local Value = math.clamp(data.current / data.total, 0, 1)
        local real_value = math.round((data.total * 10) * Value)
        Evaluation.armor = real_value
        -- runs displayed armor value changes
    end)

end

if string.lower(RequiredScript) == "lib/managers/hud/hudteammate" then
    Hooks:PostHook(HUDTeammate, "set_health", "set_health_pain_simulation", function(self, data, ...)
        local Value = math.clamp(data.current / data.total, 0, 1)
        local real_value = math.round((data.total * 10) * Value)
        Evaluation.hp = real_value
        -- runs when displayed health value changes
    end)

end

if string.lower(RequiredScript) == "lib/managers/playermanager" then
    Hooks:PostHook(PlayerManager, "on_killshot", "on_killshot_pain_simulation", function(self, killed_unit, variant, headshot, weapon_id, ...)
        local player_unit = self:player_unit()

        if not player_unit then
            return
        end

        if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
            return
        end

        dohttpreq("http://localhost:8001/evaluate/killshot", function(data2)
        end)
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

function Evaluation:UpdatePlayertag()
    dohttpreq("http://localhost:8001/evaluate/change_playertag/"..PainSimulationOptions:Playertag(), function(data2)
    end)
end

function Evaluation:saveEvalFile()
    log("save Eval File")

    dohttpreq("http://localhost:8001/evaluate/saveevalfile", function(data2)
    end)
end

function Evaluation:hpAndArmor()
    log("painevent Hp and Armor save")
    dohttpreq("http://localhost:8001/evaluate/sethp/"..Evaluation.hp.."?armor="..Evaluation.armor, function(data2)
    end)
end


function Evaluation:tased()
    dohttpreq("http://localhost:8001/evaluate/tased", function(data2)
    end)
end

if string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
    Hooks:PostHook(PlayerDamage, "restore_health","restore_health_pain_simulation", function(self)
        log("replenish hp (as perk)")
        dohttpreq("http://localhost:8001/evaluate/restore_hp", function(data2)
        end)
        Evaluation:hpAndArmor()
        -- this runs after armor regenerateArmor a few times - if you have the perk/skill in the game
    end)
end


if string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
    Hooks:PostHook(PlayerDamage, "_regenerate_armor", "_regenerate_armor_pain_event", function(self, no_sound)
        dohttpreq("http://localhost:8001/evaluate/regeneratearmor", function(data2)
        end)

        -- armor regenerating itself after not being attacked for a few seconds
    end)

end

if string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
    Hooks:PostHook(PlayerDamage, "recover_health","recover_health_event", function(self)
        log("doctor bag used")
        dohttpreq("http://localhost:8001/evaluate/doctor_bag_used", function(data2)
        end)
        Evaluation:hpAndArmor()
        -- runs when doctor bag is used
    end)

end

if string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
    Hooks:PostHook(PlayerDamage, "set_armor","set_armor_playerdamage_pain_simulation", function(self)
        log("set_armor")

        Evaluation:hpAndArmor()
        -- runs anytime armor is set, armor goes up over a few calls
    end)

end

if string.lower(RequiredScript) == "lib/units/beings/player/playerdamage" then
    Hooks:PostHook(PlayerDamage, "set_health","set_health_playerdamage_pain_simulation", function(self)
        log("set_health")
        Evaluation:hpAndArmor()
        -- runs anytime hp is set
    end)

end

if string.lower(RequiredScript) == "lib/managers/hud/hudhitconfirmed" then
    Hooks:PostHook(HUDHitConfirm, "on_hit_confirmed","on_hit_confirmed_pain_simulation", function(self, damage_scale)
        log("on hit confirmed")
        dohttpreq("http://localhost:8001/evaluate/enemy_hit", function(data2)
        end)
    end)

end

-- thanks to https://modworkshop.net/mod/16984 by Schmuddel for finding which one
-- of the many many headshot functions is actually run by the game
if string.lower(RequiredScript) == "lib/managers/playermanager" then
    Hooks:PostHook(PlayerManager, "on_headshot_dealt","on_headshot_dealt_pain_simulation", function(self)
        log("on headshot dealt")
        dohttpreq("http://localhost:8001/evaluate/enemy_headshot", function(data2)
        end)
    end)
end

if string.lower(RequiredScript) == "lib/managers/hud/hudobjectives" then
    Hooks:PostHook(HUDObjectives, "complete_objective", "complete_objective_pain_simulation", function(self, data)
        log("complete_objective" .. data.text)
        dohttpreq("http://localhost:8001/evaluate/complete_objective/" .. data.text:gsub(" ","_"), function(data2)
        end)
        -- runs wenn objective (game goal) is completed
    end)
end

if string.lower(RequiredScript) == "lib/managers/hud/hudobjectives" then
    Hooks:PostHook(HUDObjectives, "activate_objective", "activate_objective_pain_simulation", function(self, data)
        log("activate_objective" .. data.text)
        dohttpreq("http://localhost:8001/evaluate/activate_objective/"..data.text:gsub(" ","_"), function(data2)
        end)
        -- runs when new in game objective (game goal) starts
    end)
end

-- how often does the player shoot?
if string.lower(RequiredScript) == "lib/units/weapons/projectileweaponbase" then
    Hooks:PostHook(ProjectileWeaponBase, "_fire_raycast", "_fire_raycast_pain_simulation",
            function(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
                log("hoi there it is I, the projectileWeaponBase raycast")
                -- runs on granade launcher shot
                dohttpreq("http://localhost:8001/evaluate/granadelauncher_shot/", function(data2)
                end)
            end)

end

-- runs everytime the player shoots any weapon
if string.lower(RequiredScript) == "lib/managers/statisticsmanager" then
    Hooks:PostHook(StatisticsManager, "shot_fired", "shot_fired_pain_simulation", function(self, data)
        -- log("hoho, you are approaching me? Well I can't kick the shit out of the <StatisticsManager shot fired> if I don't!")
        local hit_count = 0
        if data.hit then
            hit_count = data.hit_count or 1
        end
        dohttpreq("http://localhost:8001/evaluate/weapon_fired/"..hit_count, function(data2)
        end)
    end)

    Hooks:PostHook(StatisticsManager, "health_subtracted", "health_subtracted_pain_simulation", function(self, amount)
        dohttpreq("http://localhost:8001/evaluate/health_subtracted/"..amount, function(data2)
        end)
    end)
end


if string.lower(RequiredScript) == "lib/units/beings/player/states/playerstandard" then
    Hooks:PostHook(PlayerStandard, "_stance_entered", "_stance_entered_pain_simulation", function(self, unequipped)
        if self._state_data.ducking then
            dohttpreq("http://localhost:8001/evaluate/stance_crouched/"..1, function(data2)
            end)
        else
            dohttpreq("http://localhost:8001/evaluate/stance_crouched/"..0, function(data2)
            end)
        end
    end)
end

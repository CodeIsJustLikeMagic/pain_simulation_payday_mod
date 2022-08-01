-- evaluation data

if not Evaluation then
    _G.Evaluation = {}
end

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
end)

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

function Evaluation:levelLoad()
    dohttpreq("http://localhost:8001/evaluate/levelload", function(data2)
    end)
end

function Evaluation:levelQuit()
    dohttpreq("http://localhost:8001/evaluate/levelquit", function(data2)
    end)
end

function Evaluation:hpAndArmor()
    log("painevent Hp and Armor save")
    dohttpreq("http://localhost:8001/evaluate/sethp/"..MyPlayer.hp.."?armor="..MyPlayer.armor, function(data2)
    end)
end

function Evaluation:regenerateArmor()
    dohttpreq("http://localhost:8001/evaluate/regeneratearmor", function(data2)
    end)
end

Hooks:PostHook(PlayerDamage, "restore_health","restore_health_pain_event", function(self)
    log("painevent replenish")
    dohttpreq("http://localhost:8001/evaluate/restore_hp/", function(data2)
    end)
    Evaluation:hpAndArmor()
    -- this runs after armor regenerateArmor a few times
end)

Hooks:PostHook(PlayerDamage, "recover_health","recover_health_event", function(self)
    log("painevent doctor bag used")
    dohttpreq("http://localhost:8001/evaluate/doctor_bag_used/", function(data2)
    end)
    Evaluation:hpAndArmor()
    -- runs when doctor bag is used
end)

Hooks:PostHook(PlayerDamage, "set_armor","set_armor_playerdamage_pain_event", function(self)
    log("painevent set_armor")

    Evaluation:hpAndArmor()
    -- runs anytime armor is set, armor goes up over a few calls
end)

Hooks:PostHook(PlayerDamage, "set_health","set_armor_playerdamage_pain_event", function(self)
    log("painevent set_armor")
    Evaluation:hpAndArmor()
    -- runs anytime hp is set
end)

Hooks:PostHook(HuskPlayerDamage, "_send_damage_to_owner","_send_damage_to_owner_pain_event", function(self, attack_data)
    log("painevent enemy damaged")
    dohttpreq("http://localhost:8001/evaluate/enemy_damaged", function(data2)
    end)
end)

Hooks:PostHook(HuskPlayerDamage, "init","_husk_player_damage_init_pain_event", function(self, unit)
    log("painevent HuskPlayerDamage init")
    dohttpreq("http://localhost:8001/evaluate/enemy_damaged", function(data2)
    end)
end)


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
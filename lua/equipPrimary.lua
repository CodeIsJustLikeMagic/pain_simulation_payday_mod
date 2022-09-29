-- equip primary weapon at start of game for less confusion with testers
-- slightly modified from "Equip Your Primary" mod by Sora: https://modworkshop.net/mod/24459


Hooks:PostHook(PlayerStandard, "init", "PlayerStandard_init_pain_event", function(self, unit)
-- running this in init instead of in _enter like Sora originally did. This way the primary isn't auto-selected after throwing bags

    if PainSimulationOptions.EquipPrimaryEnabled() then
        local equipped_selection = self._unit:inventory():equipped_selection()

        if equipped_selection ~= 2 then
            self._ext_inventory:equip_selection(1, false)

            DelayedCalls:Add("wtf_ovk_you_really_suckz01", 3, function() -- Larger delay so secondary weapon isn't invisible once you swap
                self._ext_inventory:equip_selection(2, false)
                managers.upgrades:setup_current_weapon()
            end)

        end
    end
end)
if not PainSimulationOptions then
    _G.PainSimulationOptions = {}
    PainSimulationOptions._settings_path = ModPath .. "menu/PainSimulationSettings.txt"
    PainSimulationOptions._menu_path = ModPath .. "menu/menu.txt"
    PainSimulationOptions.profiles = {
        "Profile0.json", "Profile1.json", "Profile2.json", "Profile3.json", "Profile4.json", "Profile5.json"
    }
    PainSimulationOptions._settings = {
        enabled = true,
        feedback_profile = 1
    }
    PainSimulationOptions.playertag = "Player1"
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_PainSimulation", function(menu_manager, nodes)

    MenuCallbackHandler.callback_pain_simulation_enabled = function(self,item)
        local state = item:value() == "on"
        PainSimulationOptions._settings.enabled = state
        PainSimulationOptions:save()
    end

    MenuCallbackHandler.callback_pain_simulation_multiple_choice = function(self, item)
        PainSimulationOptions._settings.feedback_profile = item:value()
        PainSimulationOptions:save()
    end

    function PainSimulationOptions:load()
        local file = io.open(PainSimulationOptions._settings_path,'r')
        if file then
            for k, v in pairs(json.decode(file:read('*all'))) do
                PainSimulationOptions._settings[k] = v
                log("PainSimulation load settings "..k.." is "..tostring(v))
            end
            file.close()
        else
            PainSimulationOptions:save()
        end
    end

    function PainSimulationOptions:save()
        local file = io.open(PainSimulationOptions._settings_path, 'w+')
        if file then
            file:write(json.encode(PainSimulationOptions._settings))
            file:close()
        end
    end

    function PainSimulationOptions:reset_option()
        local file = io.open(PainSimulationOptions._settings_path, 'r')
        if file then
            file:close()
            os.remove(PainSimulationOptions._settings_path)
        end
        log("PainSimulation RESET OPTIONS FILE")
    end

    PainSimulationOptions:load()

    MenuHelper:LoadFromJsonFile(PainSimulationOptions._menu_path, PainSimulationOptions, PainSimulationOptions._settings)

end)

function PainSimulationOptions:IsEnabled()
    return PainSimulationOptions._settings.enabled
end

function PainSimulationOptions:GetProfile()
    if PainSimulationOptions._settings.enabled == false then
        return "Profile0.json"
    end
    return PainSimulationOptions.profiles[PainSimulationOptions._settings.feedback_profile]
end

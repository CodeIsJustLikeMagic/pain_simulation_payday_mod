if not PainSimulationOptions then
    _G.PainSimulationOptions = {}
    PainSimulationOptions._settings_path = ModPath .. "menu/PainSimulationSettings.txt"
    PainSimulationOptions._menu_path = ModPath .. "menu/menu.txt"
    PainSimulationOptions.profiles = {
        "Profile0", "Profile1", "Profile2"
    }
    PainSimulationOptions._settings = {
        enabled = true,
        profile_name = "Profile1"
    }
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_PainSimulation", function(menu_manager, nodes)

    MenuCallbackHandler.callback_pain_simulation_enabled = function(self,item)
        local state = item:value() == "on"
        PainSimulationOptions._settings.enabled = state
        PainSimulationOptions:save()
    end

    MenuCallbackHandler.callback_pain_simulation_multiple_choice = function(self, item)
        log("PainSimulation save pain simulation multiple choice "..tostring(item:name()) .. " is "..tostring(item:value()))
        PainSimulationOptions._settings[item:name()] = item:value()
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
    return PainSimulationOptions._settings.profile_name
end

function PainSimulationOptions:SetProfile(profile_name)
    PainSimulationOptions._settings.profile_name = profile_name
end

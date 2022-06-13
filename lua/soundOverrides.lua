-- sound changes

if not PainEvent then
    _G.PainEvent = {}
    PainEvent._path = ModPath
    PainEvent.effect1_hud_panel = "Pain_event_hit_visual_effect_hud_panel"
    PainEvent.effect1_timer = 0
    PainEvent.effect1_duration = 0.2
    PainEvent.effect1_path = "assets/guis/textures/leech_ampule_effect"
    PainEvent.effect1_color = "000000"
    PainEvent.effect1_layer = 0

    PainEvent.sound1_path = PainEvent._path .. "assets/sounds/squelsh hit__.ogg"

end

--local hitsounds_portal = ThisModPath .. "assets/sounds/obi-wan-hello-there.ogg"

--if not io.file_is_readable(hitsounds_portal) then
--    log("painevent ERROR cannot find filepath " .. hitsounds_portal)
--end

if blt.xaudio then
    blt.xaudio.setup()
    log("painevent setup xAudio")
end

-- load texture files so game can find them later
for _, file in pairs(file.GetFiles(PainEvent._path.. "assets/guis/textures/")) do
    DB:create_entry(Idstring("texture"), Idstring("assets/guis/textures/".. file:gsub(".texture", "")), PainEvent._path.. "assets/guis/textures/".. file)
end
log("painevent successfully loaded texture files")

Hooks:PostHook(PlayerDamage, "init", "init_pain_event", function(self)
    log("painevent playerdamage init")

    -- prepare hud element with the texture. hud made visble when player takes damage
    local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    if not hud.panel:child(PainEvent.effect1_hud_panel) then
        local Pain_event_hit_visual_effect_hud_panel = hud.panel:bitmap({
            name = PainEvent.effect1_hud_panel,
            visible = false,
            texture = PainEvent.effect1_path,
            layer = PainEvent.effect1_layer,
            color = Color(PainEvent.effect1_color),
            blend_mode = "disable",

            w = hud.panel:w(),
            h = hud.panel:h(),
            x = 0,
            y = 0
        })
    end

    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
    managers.player:register_message(Message.OnPlayerDodge, "onDodge_pain_event", function()
        log("painevent running my sound")
        --XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path)):set_volume(1)
        log("painevent running my sound done")
    end)

    managers.player:unregister_message(Message.OnPlayerDamage, "onDamage_pain_event")
    managers.player:register_message(Message.OnPlayerDamage, "onDamage_pain_event", function()
        log("painevent running on player damage registered message")
        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(PainEvent.sound1_path)):set_volume(1)
        PainEvent.effect1_timer = PainEvent.effect1_duration
        log("painevent effect timer is ", PainEvent.effect1_timer)
    end)

end)

local function Effect_update(t, dt)
    log("painevent update effect1_timer is "..PainEvent.effect1_timer)
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    local effect_hud_panel = hud.panel:child(PainEvent.effect1_hud_panel)
    if not effect_hud_panel then
        log("painevent Error pain event effect panel not found")
        return
    end

    if PainEvent.effect1_timer > 0 then
        log("painevent set visible delta time is"..TimerManager:main():delta_time())
        PainEvent.effect1_timer = PainEvent.effect1_timer - TimerManager:main():delta_time()
        effect_hud_panel:set_visible(true)
        local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
        effect_hud_panel:animate(hudinfo.flash_icon, 4000000000)
    elseif PainEvent.effect1_timer <=0 then
        effect_hud_panel:stop()
        effect_hud_panel:set_visible(false)
    end

end

Hooks:PreHook(PlayerDamage, "pre_destroy", "pre_destory_pain_event", function(self)
    log("painevent playerdamage pre destroy")
    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
end)

if string.lower(RequiredScript) == "lib/managers/hudmanager" then
    Hooks:PostHook(HUDManager, "update", "update_pain_event", function(self, t, dt)
        Effect_update(t, dt)
    end)
end


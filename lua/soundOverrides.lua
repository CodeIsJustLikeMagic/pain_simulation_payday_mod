-- sound changes
local ThisModPath = ModPath
local snd_path = ThisModPath .. "assets/duckquack.ogg"
local snd_path2 = ThisModPath .. "assets/obi-wan-hello-there-adjusted.ogg"
local ampule_effect_path = ThisModPath .. "assets/guis/textures/leech_ampule_effect.texture"

if not io.file_is_readable(snd_path) then
    log("painevent ERROR cannot find filepath " .. snd_path)
end
if blt.xaudio and io.file_is_readable(snd_path) then
    blt.xaudio.setup()
    log("painevent setup xAudio")
else
    return
    log("painevent ERROR stopping mod !!!")
end

if io.file_is_readable(ThisModPath .. "assets/guis/textures/hello_there.texture") then
    log("painevent can find texture :)")
end


Hooks:PostHook(PlayerDamage, "init", "init_pain_event", function(self)
    log("painevent playerdamage init")

    -- prepare hud element with the texture. hud made visble when player takes damage
    local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    if not hud.panel:child("Pain_event_hit_visual_effect_hud_panel") then
        local Pain_event_hit_visual_effect_hud_panel = hud.panel:bitmap({
            name = "Pain_event_hit_visual_effect_hud_panel",
            visible = false,
            texture = "assets/guis/textures/leech_ampule_effect",
            layer = 0,
            color = Color("00ff80"),
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
        log("painevent running my sound")
        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path2)):set_volume(1)

        local hud_panel = hud.panel:child("Pain_event_hit_visual_effect_hud_panel")
        if hud_panel then
            hud_panel:set_visible(true)
            --local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
            --hud_panel:animate(hudinfo.flash_icon, 4000000000)
        end

        log("painevent running my sound done")
    end)

    log("painevent registered Message that plays sound on dodge soundpath: " .. snd_path)
end)

Hooks:PreHook(PlayerDamage, "pre_destroy", "pre_destory_pain_event", function(self)
    log("painevent playerdamage pre destroy")
    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
end)
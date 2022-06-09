-- sound changes
local ThisModPath = ModPath
local duck_sound = ThisModPath .. "assets/duckquack.ogg"
local hello_there_sound = ThisModPath .. "assets/obi-wan-hello-there-adjusted.ogg"

local hitsounds_portal = ThisModPath .. "assets/sounds/output.ogg"

--effect1
local effect1_path = "assets/guis/textures/leech_ampule_effect"
local effect1_duration = 0.5
local effect1_timer = 2

if not io.file_is_readable(hitsounds_portal) then
    log("painevent ERROR cannot find filepath " .. hitsounds_portal)
end

if blt.xaudio then
    blt.xaudio.setup()
    log("painevent setup xAudio")
end

-- load texture files so game can find them later
for _, file in pairs(file.GetFiles(ThisModPath.. "assets/guis/textures/")) do
    DB:create_entry(Idstring("texture"), Idstring("assets/guis/textures/".. file:gsub(".texture", "")), ThisModPath.. "assets/guis/textures/".. file)
end
log("painevent successfully loaded texture files")

Hooks:PostHook(PlayerDamage, "init", "init_pain_event", function(self)
    log("painevent playerdamage init")

    -- prepare hud element with the texture. hud made visble when player takes damage
    local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    if not hud.panel:child("Pain_event_hit_visual_effect_hud_panel") then
        local Pain_event_hit_visual_effect_hud_panel = hud.panel:bitmap({
            name = "Pain_event_hit_visual_effect_hud_panel",
            visible = false,
            texture = effect1_path,
            layer = 0,
            color = Color("000000"),
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
        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(hitsounds_portal)):set_volume(1)
        effect1_timer = effect1_duration
        log("painevent effect timer is ", effect1_timer)
        --local hud_panel = hud.panel:child("Pain_event_hit_visual_effect_hud_panel")
        --if hud_panel then
            --hud_panel:set_visible(true)
            --local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
            --hud_panel:animate(hudinfo.flash_icon, 4000000000)
        --end

    end)

end)

local function Effect_update(t, dt)
    log("painevent update")
    local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
    local effect_hud_panel = hud.panel:child("Pain_event_hit_visual_effect_hud_panel")
    if not effect_hud_panel then
        return
    end

    if effect1_timer > 0 then
        effect1_timer = effect1_timer - TimerManager:main():delta_time()
        effect_hud_panel:set_visible(true)
    elseif effect1_timer <=0 then
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


-- sound changes
local ThisModPath = ModPath
local snd_path = ThisModPath .. "assets/duckquack.ogg"
local snd_path2 = ThisModPath .. "assets/obi-wan-hello-there-adjusted.ogg"

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


Hooks:PostHook(PlayerDamage, "init", "init_pain_event", function(self)
    log("painevent playerdamage init")
    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
    managers.player:register_message(Message.OnPlayerDodge, "onDodge_pain_event", function()
        log("painevent running my sound")
        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path)):set_volume(1)
        log("painevent running my sound done")
    end)

    managers.player:unregister_message(Message.OnPlayerDamage, "onDamage_pain_event")
    managers.player:register_message(Message.OnPlayerDamage, "onDamage_pain_event", function()
        log("painevent running my sound")
        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path2)):set_volume(1)
        log("painevent running my sound done")
    end)

    log("painevent registered Message that plays sound on dodge soundpath: " .. snd_path)
end)

Hooks:PreHook(PlayerDamage, "pre_destroy", "pre_destory_pain_event", function(self)
    log("painevent playerdamage pre destroy")
    managers.player:unregister_message(Message.OnPlayerDodge, "onDodge_pain_event")
end)
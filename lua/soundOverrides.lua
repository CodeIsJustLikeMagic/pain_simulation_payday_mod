-- sound changes
local ThisModPath = ModPath
local snd_path = ThisModPath .. "assets/duckquack.ogg"
local snd_path2 = ThisModPath .. "assets/obi-wan-hello-there.ogg"

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

local mod_ids = Idstring(ThisModPath):key()
local hook1 = "F"..Idstring("hook1::"..mod_ids):key()
local hook2 = "F"..Idstring("hook2::"..mod_ids):key()
local msgr1 = "F"..Idstring("msgr1::"..mod_ids):key()

Hooks:PostHook(PlayerDamage, "init", hook1, function(self)
    log("painevent playerdamage init")
    managers.player:unregister_message(Message.OnPlayerDodge, msgr1)
    managers.player:register_message(Message.OnPlayerDodge, msgr1, function()
        log("painevent running my sound")
        XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path)):set_volume(1)
        log("painevent running my sound done")
    end)
    log("painevent registered Message that plays sound on dodge soundpath: " .. snd_path)
end)

Hooks:PreHook(PlayerDamage, "pre_destroy", hook2, function(self)
    log("painevent playerdamage pre destroy")
    managers.player:unregister_message(Message.OnPlayerDodge, msgr1)
end)
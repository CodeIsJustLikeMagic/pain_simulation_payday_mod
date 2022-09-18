-- Immersive Dodge Sounds by Dr_Newbie & Aurelius v 1.2
-- the ugliest integration of a secondary mod you've ever seen.
-- but I want to be able to enable and disable the mod, based on Pain Simulation profiles

local ThisModPath = ModPath

if blt.xaudio then
	blt.xaudio.setup()
else
	return
end

local mod_ids = Idstring(ThisModPath):key()
local hook1 = "F"..Idstring("hook1::"..mod_ids):key()
local hook2 = "F"..Idstring("hook2::"..mod_ids):key()
local msgr1 = "F"..Idstring("msgr1::"..mod_ids):key()

Hooks:PostHook(PlayerDamage, "init", hook1, function(self)
	log("painsimulation immersive dodge sound hook")
	managers.player:unregister_message(Message.OnPlayerDodge, msgr1)
	managers.player:register_message(Message.OnPlayerDodge, msgr1, function()
		if not Simulation.EnableImmersiveDodgeSounds then
			log("painsimulation immersive dodge sounds not enabled")
			return
		end
		log("painsimulation running immersive dodge sound")
		local ThisOGGPath		
		local __rnd = math.random(1, 90)		
		if __rnd == 1 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge1.ogg"
		elseif __rnd == 2 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge2.ogg"
		elseif __rnd == 3 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge3.ogg"
		elseif __rnd == 4 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge4.ogg"
		elseif __rnd == 5 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge5.ogg"
		elseif __rnd == 6 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge6.ogg"
		elseif __rnd == 7 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge7.ogg"	
		elseif __rnd == 8 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge8.ogg"	
		elseif __rnd == 9 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge9.ogg"	
		elseif __rnd == 10 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge10.ogg"
		elseif __rnd == 11 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge11.ogg"	
		elseif __rnd == 12 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge12.ogg"	
		elseif __rnd == 13 then
			ThisOGGPath = "assets/sounds/Dodge_L/dodge13.ogg"
		elseif __rnd == 14 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge1.ogg"
		elseif __rnd == 15 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge2.ogg"
		elseif __rnd == 16 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge3.ogg"
		elseif __rnd == 17 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge4.ogg"
		elseif __rnd == 18 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge5.ogg"
		elseif __rnd == 19 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge6.ogg"
		elseif __rnd == 20 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge7.ogg"	
		elseif __rnd == 21 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge8.ogg"	
		elseif __rnd == 22 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge9.ogg"	
		elseif __rnd == 23 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge10.ogg"
		elseif __rnd == 24 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge11.ogg"	
		elseif __rnd == 25 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge12.ogg"	
		elseif __rnd == 26 then
			ThisOGGPath = "assets/sounds/Dodge_L/High/dodge13.ogg"
		elseif __rnd == 27 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge1.ogg"
		elseif __rnd == 28 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge2.ogg"
		elseif __rnd == 29 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge3.ogg"
		elseif __rnd == 30 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge4.ogg"
		elseif __rnd == 31 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge5.ogg"
		elseif __rnd == 32 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge6.ogg"
		elseif __rnd == 33 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge7.ogg"	
		elseif __rnd == 34 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge8.ogg"	
		elseif __rnd == 35 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge9.ogg"	
		elseif __rnd == 36 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge10.ogg"
		elseif __rnd == 37 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge11.ogg"	
		elseif __rnd == 38 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge12.ogg"	
		elseif __rnd == 39 then
			ThisOGGPath = "assets/sounds/Dodge_L/Low/dodge13.ogg"
		elseif __rnd == 40 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge1.ogg"
		elseif __rnd == 41 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge2.ogg"
		elseif __rnd == 42 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge3.ogg"
		elseif __rnd == 43 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge4.ogg"
		elseif __rnd == 44 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge5.ogg"
		elseif __rnd == 45 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge6.ogg"
		elseif __rnd == 46 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge7.ogg"	
		elseif __rnd == 47 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge8.ogg"	
		elseif __rnd == 48 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge9.ogg"	
		elseif __rnd == 49 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge10.ogg"
		elseif __rnd == 50 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge11.ogg"	
		elseif __rnd == 51 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge12.ogg"	
		elseif __rnd == 52 then
			ThisOGGPath = "assets/sounds/Dodge_R/dodge13.ogg"
		elseif __rnd == 53 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge1.ogg"
		elseif __rnd == 54 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge2.ogg"
		elseif __rnd == 55 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge3.ogg"
		elseif __rnd == 56 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge4.ogg"
		elseif __rnd == 57 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge5.ogg"
		elseif __rnd == 58 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge6.ogg"
		elseif __rnd == 59 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge7.ogg"	
		elseif __rnd == 60 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge8.ogg"	
		elseif __rnd == 61 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge9.ogg"	
		elseif __rnd == 62 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge10.ogg"
		elseif __rnd == 63 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge11.ogg"	
		elseif __rnd == 64 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge12.ogg"	
		elseif __rnd == 65 then
			ThisOGGPath = "assets/sounds/Dodge_R/High/dodge13.ogg"
		elseif __rnd == 66 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge1.ogg"
		elseif __rnd == 67 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge2.ogg"
		elseif __rnd == 68 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge3.ogg"
		elseif __rnd == 69 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge4.ogg"
		elseif __rnd == 70 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge5.ogg"
		elseif __rnd == 71 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge6.ogg"
		elseif __rnd == 72 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge7.ogg"	
		elseif __rnd == 73 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge8.ogg"	
		elseif __rnd == 74 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge9.ogg"	
		elseif __rnd == 75 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge10.ogg"
		elseif __rnd == 76 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge11.ogg"	
		elseif __rnd == 77 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge12.ogg"	
		elseif __rnd == 78 then
			ThisOGGPath = "assets/sounds/Dodge_R/Low/dodge13.ogg"							
		else
			ThisOGGPath = "assets/sounds/silence.ogg"
		end
		ThisOGGPath = ThisModPath .. ThisOGGPath
		if io.file_is_readable(ThisOGGPath) then
			XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(ThisOGGPath))
		end
	end)
end)

Hooks:PreHook(PlayerDamage, "pre_destroy", hook2, function(self)
	managers.player:unregister_message(Message.OnPlayerDodge, msgr1)
end)
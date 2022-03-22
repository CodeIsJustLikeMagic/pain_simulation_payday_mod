function HUDTeammate:set_health(data)
	self._health_data = data
	local teammate_panel = self._panel:child("player")
	local radial_health_panel = self._radial_health_panel
	local radial_health = radial_health_panel:child("radial_health")
	local radial_rip = radial_health_panel:child("radial_rip")
	local radial_rip_bg = radial_health_panel:child("radial_rip_bg")
	local red = data.current / data.total


	if managers.player:has_activate_temporary_upgrade("temporary", "copr_ability") and self._id == HUDManager.PLAYER_PANEL then
		local static_damage_ratio = managers.player:upgrade_value_nil("player", "copr_static_damage_ratio")

		if static_damage_ratio then
			red = math.floor((red + 0.01) / static_damage_ratio) * static_damage_ratio
		end

		local copr_overlay_panel = radial_health_panel:child("copr_overlay_panel")

		if alive(copr_overlay_panel) then
			for _, notch in ipairs(copr_overlay_panel:children()) do
				notch:set_visible(notch:script().red <= red + 0.01)
			end
		end
	end

	radial_health:stop()

	if red < radial_health:color().red then
		self:_damage_taken()
		radial_health:set_color(Color(1, red, 1, 1))

		if alive(radial_rip) then
			radial_rip:set_rotation((1 - radial_health:color().r) * 360)
			radial_rip_bg:set_rotation((1 - radial_health:color().r) * 360)
		end

		self:update_delayed_damage()
	else
		radial_health:animate(function (o)
			local s = radial_health:color().r
			local e = red
			local health_ratio = nil

			over(0.2, function (p)
				health_ratio = math.lerp(s, e, p)

				radial_health:set_color(Color(1, health_ratio, 1, 1))

				if alive(radial_rip) then
					radial_rip:set_rotation((1 - radial_health:color().r) * 360)
					radial_rip_bg:set_rotation((1 - radial_health:color().r) * 360)
				end

				self:update_delayed_damage()

				local copr_overlay_panel = radial_health_panel:child("copr_overlay_panel")

				if alive(copr_overlay_panel) then
					for _, notch in ipairs(copr_overlay_panel:children()) do
						notch:set_visible(notch:script().red <= health_ratio + 0.01)
					end
				end
			end)
		end)
	end
end
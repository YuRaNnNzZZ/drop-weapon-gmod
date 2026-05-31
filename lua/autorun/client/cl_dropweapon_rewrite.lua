-- Drop Weapon Addon
-- by YuRaNnNzZZ

-- If you reading this: i'm not responsible for eyes bleeding after reading my code :V

-- local cv_autoswitch = CreateClientConVar("cl_dropweapon_useonpickup", "0", true, true, "Should player switch to picked up weapon? (dropped only)") -- disabled by default because it's annoying

hook.Add("PopulateToolMenu", "DropWeapon_ToolMenu", function()
	-- spawnmenu.AddToolMenuOption( "Utilities", "Drop Weapon", "DropWeapon_Client", "Client", "", "", function(panel)
	-- 	panel:ClearControls()

	-- 	panel:CheckBox("#dropweapon_menu_cl_autoswitch", cv_autoswitch:GetName())
	-- end)

	spawnmenu.AddToolMenuOption( "Utilities", "Drop Weapon", "DropWeapon_Server", "Server", "", "", function(panel)
		panel:ClearControls()

		panel:CheckBox("#dropweapon_menu_sv_blacklist_adminbypass", "sv_dropweapon_blacklist_adminbypass")

		panel:AddControl("Label", {Text = ""}) -- spacer

		panel:CheckBox("#dropweapon_menu_sv_ondeath", "sv_dropweapon_ondeath")
		panel:CheckBox("#dropweapon_menu_sv_ondeath_activeonly", "sv_dropweapon_ondeath_activeonly")
	end)
end)
-- Drop Weapon Addon
-- by YuRaNnNzZZ

-- If you reading this: i'm not responsible for eyes bleeding after reading my code :V

local dropcommand = "+drop"
local cv_lang = GetConVar("gmod_language")
local cv_autoswitch = CreateClientConVar("cl_dropweapon_useonpickup", "0", true, true, "Should player switch to picked up weapon? (dropped only)") -- disabled by default because it's annoying

local lang_strings = {
	["dropweapon_menu_cl_autoswitch"] = {
		["en"] = "Auto-switch to picked up weapon",
		["ru"] = "Авто-переключение на подобранное оружие"
	},
	["dropweapon_menu_sv_blacklist"] = {
		["en"] = "Blacklist",
		["ru"] = "Чёрный список"
	},
	["dropweapon_menu_sv_blacklist_adminbypass"] = {
		["en"] = "Admins can bypass blacklist",
		["ru"] = "Могут ли админы игнорировать чёрный список"
	},
	["dropweapon_menu_sv_ondeath"] = {
		["en"] = "Drop weapons on death",
		["ru"] = "Выбрасывать оружия после смерти"
	},
	["dropweapon_menu_sv_ondeath_activeonly"] = {
		["en"] = "Drop only active weapon on death",
		["ru"] = "Выбрасывать только оружие в руках после смерти"
	},
	["dropweapon_bindnag"] = {
		["en"] = "You don't have key bound for weapon dropping.\nTo bind a key, type \"bind <key> %s\" in the console.",
		["ru"] = "У вас не назначена клавиша для выбрасывания оружия.\nДля того, чтобы назначить клавишу, выполните в консоли команду \"bind <клавиша> %s\"."
	}
}

local function GetLocalizedString(index)
	local lang = cv_lang:GetString()
	local strtbl = lang_strings[index]
	if not strtbl then return index end

	return strtbl[lang] or strtbl["en"] or "#" .. index
end

hook.Add("HUDPaint", "DropWeapon_BindNag", function()
	local ply = LocalPlayer()

	if IsValid(ply) then
		local bind = input.LookupBinding(dropcommand, true)

		if not bind or bind == "no value" then
			ply:ChatPrint(string.format(GetLocalizedString("dropweapon_bindnag"), dropcommand))
		end

		hook.Remove("HUDPaint", "DropWeapon_BindNag")
	end
end)

hook.Add("PopulateToolMenu", "DropWeapon_ToolMenu", function()
	spawnmenu.AddToolMenuOption( "Utilities", "Drop Weapon", "DropWeapon_Client", "Client", "", "", function(panel)
		panel:ClearControls()

		panel:CheckBox(GetLocalizedString("dropweapon_menu_cl_autoswitch"), cv_autoswitch:GetName())
	end)

	spawnmenu.AddToolMenuOption( "Utilities", "Drop Weapon", "DropWeapon_Server", "Server", "", "", function(panel)
		panel:ClearControls()

		panel:CheckBox(GetLocalizedString("dropweapon_menu_sv_blacklist_adminbypass"), "sv_dropweapon_blacklist_adminbypass")

		panel:AddControl("Label", {Text = ""}) -- spacer

		panel:CheckBox(GetLocalizedString("dropweapon_menu_sv_ondeath"), "sv_dropweapon_ondeath")
		panel:CheckBox(GetLocalizedString("dropweapon_menu_sv_ondeath_activeonly"), "sv_dropweapon_ondeath_activeonly")
	end)
end)
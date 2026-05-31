-- Drop Weapon Addon
-- by YuRaNnNzZZ

-- If you reading this: i'm not responsible for eyes bleeding after reading my code :V

local blacklist = {}
local cv_blacklist = CreateConVar("sv_dropweapon_blacklist", "weapon_fists,", {FCVAR_ARCHIVE, FCVAR_PROTECTED}, "List of weapons classnames separated by comma that are blacklisted from dropping.")
local cv_blacklist_adminbypass = CreateConVar("sv_dropweapon_blacklist_adminbypass", "0", {FCVAR_ARCHIVE}, "Can admins drop blacklisted weapons?")
local cv_dropondeath = CreateConVar("sv_dropweapon_ondeath", "0", {FCVAR_ARCHIVE}, "Should players drop their weapons on death?")
local cv_dropondeath_activeonly = CreateConVar("sv_dropweapon_ondeath_activeonly", "1", {FCVAR_ARCHIVE}, "Should players drop their active weapon only on death? (Requires dropping weapons on death to be enabled)")
local cv_enablecommand = CreateConVar("sv_dropweapon_enablecommand", "1", {FCVAR_ARCHIVE}, "Allow players to use +drop command to drop their weapons?")

--[[local hl2ammolist = {
	["primary"] = {
		["weapon_ar2"] = 30,
		["weapon_crossbow"] = 4,
		["weapon_frag"] = 1,
		["weapon_handgrenade"] = 5,
		["weapon_rpg"] = 3,
	},
	["secondary"] = {
		["weapon_slam"] = 3,
	},
}]]--

local function StringToTable(str, separator)
	local newtable = {}
	local strings = string.Explode(separator, str)

	for _, v in pairs(strings) do
		if #v > 0 then
			newtable[v] = true
		end
	end

	return newtable
end

cvars.AddChangeCallback("sv_dropweapon_blacklist", function(cvar, oldval, newval)
	blacklist = StringToTable(newval, ",")
end, "dropweapon_blacklist")

blacklist = StringToTable(cv_blacklist:GetString(), ",")

concommand.Add("sv_dropweapon_blacklist_add", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if #args < 1 then return end
	if blacklist[args[1]] then return end
	blacklist[args[1]] = true
	local str = ""
	for k,v in pairs(blacklist) do
		if v then str = str .. k .. "," end
	end
	cv_blacklist:SetString(str)
end)

concommand.Add("sv_dropweapon_blacklist_remove", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsAdmin() then return end
	if #args < 1 then return end
	if not blacklist[args[1]] then return end
	blacklist[args[1]] = false
	local str = ""
	for k,v in pairs(blacklist) do
		if v then str = str .. k .. "," end
	end
	cv_blacklist:SetString(str)
end)

--[[local function SetAmmoOnPickup(ply, wpn)
	timer.Simple(0.01, function()
		if not IsValid(ply) or not ply:IsPlayer() or not IsValid(wpn) or not wpn.DroppedByPlayer then return end

		if not wpn:IsScripted() then
			if hl2ammolist.primary[wpn:GetClass()] then
				local ammotype = wpn:GetPrimaryAmmoType()
				local ammocount = ply:GetAmmoCount(ammotype)

				ply:SetAmmo(ammocount - hl2ammolist.primary[wpn:GetClass()], ammotype)
			end
			if hl2ammolist.secondary[wpn:GetClass()] then
				local ammotype = wpn:GetSecondaryAmmoType()
				local ammocount = ply:GetAmmoCount(ammotype)

				ply:SetAmmo(ammocount - hl2ammolist.secondary[wpn:GetClass()], ammotype)
			end
		end -- temporary solution until i figure out how to actually fix this
		-- TODO: MAKE AN ACTUAL FIX
		-- TOO BAD! THE ACTUAL FIX IS NOT POSSIBLE

		if wpn.DropClip1 and wpn:GetMaxClip1() >= 0 then
			wpn:SetClip1(wpn.DropClip1)
			wpn.DropClip1 = nil
		end

		if wpn.DropClip2 and wpn:GetMaxClip2() >= 0 then
			wpn:SetClip2(wpn.DropClip2)
			wpn.DropClip2 = nil
		end

		if wpn.Primary and wpn.Primary.DefaultClipPreDrop then
			wpn.Primary.DefaultClip = wpn.Primary.DefaultClipPreDrop
			wpn.Primary.DefaultClipPreDrop = nil
		end

		if wpn.Secondary and wpn.Secondary.DefaultClipPreDrop then
			wpn.Secondary.DefaultClip = wpn.Secondary.DefaultClipPreDrop
			wpn.Secondary.DefaultClipPreDrop = nil
		end

		if wpn.IsTFA and wpn:IsTFA() then wpn:ClearStatCache() end -- this is getting annoying

		if ply:GetInfoNum("cl_dropweapon_useonpickup", 0) > 0 then
			ply:SelectWeapon(wpn:GetClass())
		end

		wpn.DroppedByPlayer = nil
	end)
end

local function Think()
	hook.Run("DroppedWeaponThink")
end
hook.Add("Think", "DropWeapon_ThinkLoop", Think)]]--

local function DropWeapon(ply, wpn, forceblacklist)
	if not IsValid(wpn) then return end
	if (blacklist[wpn:GetClass()] or wpn.AdminOnly) and (forceblacklist or not ply:IsAdmin() or not cv_blacklist_adminbypass:GetBool()) then return end -- i don't want make separate function for this shit :V

	ply:DropWeapon(wpn)
end

concommand.Add("+drop", function(ply) if cv_enablecommand:GetBool() then DropWeapon(ply, ply:GetActiveWeapon()) end end)
concommand.Add("-drop", function(ply) end)

local function DropAllWeapons(ply)
	for _,wpn in pairs(ply:GetWeapons()) do
		DropWeapon(ply, wpn, true)
	end
end

local function DoPlayerDeath(ply, atk, dmginfo)
	if cv_dropondeath:GetBool() then
		if cv_dropondeath_activeonly:GetBool() then
			DropWeapon(ply, ply:GetActiveWeapon(), true)
		else
			DropAllWeapons(ply)
		end
	end
end
hook.Add("DoPlayerDeath", "DropWeapon_DoPlayerDeath", DoPlayerDeath)

--[[local function DroppedWeaponThink(wep) -- instead of looping through internal table we're abusing hook system now
	if not IsValid(wep) then return end

	if IsValid(wep:GetOwner()) then
		SetAmmoOnPickup(wep:GetOwner(), wep)
		hook.Remove("DroppedWeaponThink", wep)

		return
	end
end

local function PlayerDroppedWeapon(owner, wep)
	if not IsValid(wep) or not wep:IsWeapon() then return end

	if wep:Clip1() >= 0 then
		wep.DropClip1 = wep:Clip1()
	end

	if wep:Clip2() >= 0 then
		wep.DropClip2 = wep:Clip2()
	end

	if wep.Primary and not wep.Primary.DefaultClipPreDrop then
		wep.Primary.DefaultClipPreDrop = wep.Primary.DefaultClip
		wep.Primary.DefaultClip = 0
	end -- no free primary ammo

	if wep.Secondary and not wep.Secondary.DefaultClipPreDrop then
		wep.Secondary.DefaultClipPreDrop = wep.Secondary.DefaultClip
		wep.Secondary.DefaultClip = 0
	end -- no free secondary ammo either

	if wep.IsTFA and wep:IsTFA() then wep:ClearStatCache() end -- this is getting annoying

	wep.DroppedByPlayer = true

	hook.Add("DroppedWeaponThink", wep, DroppedWeaponThink)
end
hook.Add("PlayerDroppedWeapon", "DropWeapon_PlayerDroppedWeapon", PlayerDroppedWeapon)]]--
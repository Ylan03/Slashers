-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-25 16:15:46
-- @Last Modified by:   Garrus2142
-- @Last Modified time: 2017-08-09T14:10:02+02:00

local GM = GM or GAMEMODE
local scrw, scrh = ScrW(), ScrH()
local ICON_CROSS = Material("icons/icon_cross.png")
local ICON_SAFE = Material("icons/icon_safe.png")
local ICON_KEYS = Material("icons/icon_keys.png")

hook.Add("OnScreenSizeChanged", "sls_class_ScreenSize", function()
	scrw, scrh = ScrW(), ScrH()
end)

local function DrawHUDSurvivor()
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.SetMaterial(GM.CLASS.Survivors[LocalPlayer().ClassID].icon)
	surface.DrawTexturedRect(20, scrh - 84, 64, 64)
end

local function DrawHUDBlack(numberKeyToDispach)
	while numberKeyToDispach > 0 do
		surface.SetMaterial(ICON_KEYS)
		surface.DrawTexturedRect(scrw - ((64 + 20) * numberKeyToDispach), scrh - 84, 64, 64)
		numberKeyToDispach = numberKeyToDispach - 1
	end
end

local function DrawHUDKiller()
	surface.SetDrawColor(Color(255, 255, 255, 255))
	if GM.MAP.Killer.Icon then
		surface.SetMaterial(GM.MAP.Killer.Icon)
		surface.DrawTexturedRect(20, scrh - 84, 64, 64)
	end

	for k, v in ipairs(GM.ROUND.Survivors or {}) do
		if !IsValid(v) or !GM.CLASS.Survivors[v.ClassID] then continue end

		surface.SetMaterial(GM.CLASS.Survivors[v.ClassID].icon)
		surface.DrawTexturedRect(scrw - ((64 + 20) * k), scrh - 84, 64, 64)
		if !v:Alive() then
			surface.SetMaterial(v:GetNWBool("Escaped") and ICON_SAFE or ICON_CROSS)
			surface.DrawTexturedRect(scrw - ((64 + 20) * k), scrh - 84, 64, 64)
		end
	end
end

local function HUDPaint()
	local lp = LocalPlayer()
	if !IsValid(lp) then return end
	if !GM.ROUND.Active then return end
	if !lp.ClassID then return end

	if lp:Team() == TEAM_SURVIVORS && GM.CLASS.Survivors[lp.ClassID] then
		DrawHUDSurvivor()
		if lp.ClassID == CLASS_SURV_BLACK then
			-- The number of keys is read from the weapon (networked), not from a local counter
			local keys = lp:GetWeapon("weapon_keys")
			if IsValid(keys) and keys.GetKeysLeft then
				DrawHUDBlack(keys:GetKeysLeft())
			end
		end
	elseif lp:Team() == TEAM_KILLER then
		DrawHUDKiller()
	end
end
hook.Add("HUDPaint", "sls_class_HUDPaint", HUDPaint)

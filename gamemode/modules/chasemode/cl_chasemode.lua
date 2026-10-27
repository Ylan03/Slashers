-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH
-- @Date:   2017-07-26T13:54:42+02:00
-- @Last modified by:   Guilhem PECH



local Timer1 = 0
local GM = GM or GAMEMODE

local function HaveASurvivorInSight()
	local lp = LocalPlayer()
	if !IsValid(lp) or !IsValid(GM.ROUND.Killer) then return end
	if lp:Team() != TEAM_KILLER or !lp:Alive() then return end
	local curtime = CurTime()
	if Timer1 > curtime then return end
	Timer1 = curtime + 1

	for _, v in ipairs(player.GetAll()) do
		if v == lp or !v:Alive() or v:Team() != TEAM_SURVIVORS then continue end
		if lp:GetPos():DistToSqr(v:GetPos()) >= 1000 ^ 2 or !lp:IsLineOfSightClear(v) then continue end

		local ScreenPosMax = (v:GetPos() + v:OBBMaxs() - Vector(10,0,0)):ToScreen()
		local ScreenPosMin = (v:GetPos() + v:OBBMins() + Vector(10,0,0)):ToScreen()

		if (ScreenPosMax.x < ScrW() && ScreenPosMax.y < ScrH() && ScreenPosMin.x > 0 && ScreenPosMin.y > 0) then
			net.Start( "sls_killerseesurvivor" )
				net.WriteEntity( v )
				net.WriteUInt(lp:GetColor().a, 8)
			net.SendToServer()
		end
	end
end
hook.Add("Think", "sls_SurvivorInView", HaveASurvivorInSight)

local ChaseSound
local function InitValue()
	local lp = LocalPlayer()
	if !IsValid(lp) then return end

	if ChaseSound then ChaseSound:Stop() end
	ChaseSound = GM.MAP.ChaseMusic and CreateSound(lp, GM.MAP.ChaseMusic) or nil
	lp.LastViewByKillerTime = 0
	lp.ChaseSoundPlaying = false
end
hook.Add("sls_round_PostStart", "sls_chasemo_PostStart", InitValue)

local function StopChase()
	local lp = LocalPlayer()
	if ChaseSound then ChaseSound:FadeOut(1.2) end
	if IsValid(lp) then lp.ChaseSoundPlaying = false end
end
hook.Add("sls_round_End", "sls_chasemo_End", StopChase)

local function LastViewByKiller()
	LocalPlayer().LastViewByKillerTime = net.ReadFloat()
end
net.Receive( "sls_chaseactivated", LastViewByKiller)

local function chaseMusic()
	local lp = LocalPlayer()
	if !IsValid(lp) or !ChaseSound or !lp.LastViewByKillerTime then return end
	local curtime = CurTime()

	if !lp:Alive() then
		if lp.ChaseSoundPlaying then StopChase() end
		return
	end

	if lp.LastViewByKillerTime > curtime - 3 && !lp.ChaseSoundPlaying then
		lp.ChaseSoundPlaying = true
		timer.Simple(3, function()
			if !IsValid(lp) or !ChaseSound or !lp.ChaseSoundPlaying then return end
			if lp.LastViewByKillerTime > CurTime() - 3 then
				ChaseSound:Play()
			end
		end)
	elseif lp.ChaseSoundPlaying && lp.LastViewByKillerTime < curtime - 5 then
		StopChase()
	end
end
hook.Add("Think","sls_ChasemodeMusic",chaseMusic)

-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH
-- @Date:   2017-08-08T18:51:45+02:00
-- @Last Modified by:   Hyltaria
-- @Last Modified time: 2026-10-27

util.AddNetworkString( "sls_killerseesurvivor" )
util.AddNetworkString( "sls_chaseactivated" )

-- The killer's client reports which survivor he sees.
-- Everything is checked server side: before, any client could send any entity
-- (net.Send on a non player entity = Lua error).
local MAX_DIST_SQR = 1000 ^ 2

local function relayChase(len, ply)
	local target = net.ReadEntity()
	net.ReadUInt(8) -- legacy value (killer alpha), checked server side below

	local GM = GAMEMODE
	if !GM.ROUND.Active or !IsValid(GM.ROUND.Killer) or ply != GM.ROUND.Killer then return end
	if !ply:Alive() or SLS_IsInvisible(ply) then return end
	if !IsValid(target) or !target:IsPlayer() or !target:Alive() or target:Team() != TEAM_SURVIVORS then return end
	if ply:GetPos():DistToSqr(target:GetPos()) > MAX_DIST_SQR then return end

	-- Max one chase message per survivor per 0.5 s
	target.sls_nextChaseMsg = target.sls_nextChaseMsg or 0
	if target.sls_nextChaseMsg > CurTime() then return end
	target.sls_nextChaseMsg = CurTime() + 0.5

	net.Start( "sls_chaseactivated" )
		net.WriteFloat(CurTime())
	net.Send(target)
end
net.Receive( "sls_killerseesurvivor", relayChase)

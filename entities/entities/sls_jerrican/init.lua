-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH
-- @Date:   2017-07-26T13:54:42+02:00
-- @Last Modified by:   Garrus2142
-- @Last Modified time: 2017-07-26T22:25:37+02:00



local GM = GM or GAMEMODE

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()

	self.Active = false
	self:SetModel("models/props_junk/gascan001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

end

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
    local ent = ents.Create("sls_jerrican")
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
    ent:Spawn()

    return ent
end
-- (removed) ents.Create("prop_physics") at file load: created a ghost entity before the map

function ENT:OnTakeDamage(dmg)

end

function ENT:Use(ply)
	if self.sls_used then return end
	if !IsValid(ply) or !ply:IsPlayer() or !ply:Alive() then return end
	if CurrentObjective != "find_jerrican" or ply:Team() != TEAM_SURVIVORS then return end
	if !NbJerricanToFound or NbJerricanToFound <= 0 then return end

	self.sls_used = true
	NbJerricanToFound = NbJerricanToFound - 1

	net.Start( "notificationSlasher" )
		net.WriteTable({"round_mission_jerrycan_found"})
		net.WriteString("safe")
	net.Send(ply)

	net.Start( "modifyObjectiveSlasher" )
		net.WriteTable({"round_mission_jerrycan", NbJerricanToFound})
	if IsValid(GM.ROUND.Killer) then net.SendOmit(GM.ROUND.Killer) else net.Broadcast() end

	if NbJerricanToFound == 0 then
		net.Start( "objectiveSlasher" )
			net.WriteTable({"round_mission_generator"})
			net.WriteString("caution")
		if IsValid(GM.ROUND.Killer) then net.SendOmit(GM.ROUND.Killer) else net.Broadcast() end

		hook.Call("sls_NextObjective")
	end

	ply:EmitSound("player/shove_01.wav", 100, 100, 1, CHAN_AUTO)
	self:Remove()
end

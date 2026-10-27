-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH
-- @Date:   2017-07-26T13:54:42+02:00
-- @Last modified by:   Guilhem PECH
-- @Last modified time: 15-Apr-2018



local GM = GAMEMODE

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.AddNetworkString("sls_motherradar")

local function endMusic(victim)
	net.Start("sls_motherradar",true)
		net.WriteUInt(0,2)
	net.Send(victim)
end
hook.Add("PlayerDeath","slash_deathmusicend",endMusic)

function ENT:Initialize()

	self.Active = false
	self:SetModel("models/poly_wheelchair.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetNWBool('activated',false)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType( SIMPLE_USE )

	local bones = ents.Create( "prop_physics" )
	bones:SetModel( "models/skeleton/skeleton_torso.mdl" )
	bones:SetPos( self:GetPos() + Vector(-4.116044,0.400906,37.009029) )
	bones:SetAngles(self:GetAngles() + Angle(-22.855,-15.711,9.402))
	bones:SetMoveType(MOVETYPE_NONE)
	bones:SetParent(self)
	bones:Spawn()


	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(true)
		phys:Wake() 
	end

	timer.Simple( 1, function() 
		if(IsValid(self)) then
			self:SetMoveType(MOVETYPE_NONE)
		end
	end )
end

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
    local ent = ents.Create("sls_motherbates")
    ent:SetPos( tr.HitPos + tr.HitNormal )    
    ent:Spawn()

    return ent
end
-- (removed) ents.Create("prop_physics") at file load: created a ghost entity before the map


local howFar
local function sendInfo (ply,DistSqr)
	if(!IsValid(ply)) then return end
	net.Start("sls_motherradar",true)
		net.WriteUInt(howFar (DistSqr),2)
	net.Send(ply)
end

function howFar (pos)
	if (pos) < ( 500*500 ) then
		return 3
	elseif (pos) < ( 1000*1000 ) then
		return 2
	elseif (pos) < ( 1500*1500 )  then
		return 1
	else
		return 0
	end
end


function ENT:FindAroundPlayers(radius)
	local entsNearby = ents.FindInSphere( self:GetPos() , radius )
	local plyNearby = {}
	for i,v in pairs(entsNearby) do
		if (v:IsValid() and v:IsPlayer() and v:Team() ~= TEAM_KILLER and v.ClassID != CLASS_SURV_SHY) then
			plyNearby[v] = v:GetPos():DistToSqr( self:GetPos() )
			sendInfo(v,plyNearby[v])
		end
	end
	return plyNearby
end

local function ApplyModifications(ply,pos)
	if(!IsValid(ply)) then return end
	if (!ply.normWalk) then ply.normWalk = ply:GetWalkSpeed() end

	if (pos) < ( 500*500 ) then
		ply:SetWalkSpeed(ply.normWalk * 1.6)
		ply:SetRunSpeed(ply.normWalk * 1.6)
	elseif (pos) < ( 1000*1000 ) then
		ply:SetWalkSpeed(ply.normWalk * 1.4)
		ply:SetRunSpeed(ply.normWalk * 1.4)
	elseif (pos) < ( 1500*1500 )  then
		ply:SetWalkSpeed(ply.normWalk * 1.2)
		ply:SetRunSpeed(ply.normWalk * 1.2)
	else
		ply:SetWalkSpeed(ply.normWalk)
		ply:SetRunSpeed(ply.normWalk)

	end
end


function ENT:Think()
	local plyNearby = self:FindAroundPlayers(3000)
	local last = 5000*5000
	for k,v in pairs(plyNearby) do
		if v < last then
			sendInfo (GM.ROUND.Killer,v)
			ApplyModifications(GM.ROUND.Killer,v)
			last = v
		end
	end
	self:NextThink( CurTime() + 1 )
	return true
end

function ENT:OnTakeDamage(dmg)

end

function ENT:Use( activator, caller )
	if !GM.ROUND.Active or GM.ROUND.Escape then return end
	if ( IsValid(activator) && activator:IsPlayer() && activator:Alive() && activator:Team() == TEAM_SURVIVORS && !GM.ROUND.WaitingPolice) then
		CurrentObjective = "wainting_police"
		objectifComplete()
		GM.ROUND:StartWaitingPolice()
	end
end

-- Before: "if self:IsPlayer()" (never true) -> the killer kept his bonus speed
function ENT:OnRemove()
	local killer = GM.ROUND and GM.ROUND.Killer
	if IsValid(killer) and killer.normWalk then
		killer:SetWalkSpeed(killer.normWalk)
		killer:SetRunSpeed(killer.normWalk)
	end
end

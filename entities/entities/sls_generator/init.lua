-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH
-- @Date:   2017-07-26T13:54:42+02:00
-- @Last Modified by:   Garrus2142
-- @Last Modified time: 2017-07-26T22:25:56+02:00



local GM = GAMEMODE

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


sound.Add( {
	name = "engine_sound",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 75,
	pitch = { 95, 110 },
	sound = "vehicles/Crane/crane_startengine1.wav"

} )
sound.Add( {
	name = "engine_fueling",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "ambient/water/leak_1.wav"
} )

local engine_fuelingSound = Sound("ambient/water/leak_1.wav")

function ENT:Initialize()

	self.Active = false
	self:SetModel("models/props_vehicles/generatortrailer01.mdl")
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNWFloat( 'progressBar', 0 )
	self:SetNWBool( 'activated', false)
	self:SetUseType( CONTINUOUS_USE )

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create("sls_generator")
	ent:SetPos( tr.HitPos + tr.HitNormal )
	ent:Spawn()

	return ent
end


function ENT:OnTakeDamage(dmg)

end

local CV_Duration = CreateConVar("slashers_generator_duration", 5, {FCVAR_ARCHIVE}, "Time (in seconds) a survivor must hold USE to start the generator.")

function ENT:Use(activator, caller)
	if !IsValid(caller) or !caller:IsPlayer() then return end
	if self:GetNWBool('activated') then return end

	if CurrentObjective == "activate_generator" && caller:Team() == TEAM_SURVIVORS && caller:Alive() then
		local curentProgress = self:GetNWFloat('progressBar')

		-- Progress depends on time, not on the server tickrate any more
		if curentProgress < 1 then
			local step = engine.TickInterval() / math.max(CV_Duration:GetFloat(), 0.1)
			curentProgress = math.min(curentProgress + step, 1)
			self:SetNWFloat( 'progressBar', curentProgress)
			net.Start( "activateProgressionSlasher" )
			net.WriteFloat(curentProgress)
			net.Send(caller)
		end

		-- Before: GetNWEntity("activated") on a boolean returned NULL (always "true"),
		-- so the generator could never be validated.
		if curentProgress >= 1 then
			self:SetNWBool( 'activated', true)
			self:SetNWFloat( 'progressBar', 2)
			self:EmitSound( "engine_sound", 75, 100, 1, CHAN_AUTO )

			net.Start( "activateProgressionSlasher" )
			net.WriteFloat(2)
			net.Send(caller)

			net.Start( "notificationSlasher" )
			net.WriteTable({"round_notif_enabled_generator"})
			net.WriteString("safe")
			net.Send(caller)

			net.Start( "objectiveSlasher" )
			net.WriteTable({"round_mission_radio"})
			net.WriteString("caution")
			if IsValid(GM.ROUND.Killer) then
				net.SendOmit(GM.ROUND.Killer)
			else
				net.Broadcast()
			end
			self.Active = true
			hook.Call("sls_NextObjective")
		end
	elseif caller:Team() == TEAM_SURVIVORS then
		-- USE is continuous on this entity: avoid one notification per tick
		if (caller.sls_nextGeneratorNotif or 0) > CurTime() then return end
		caller.sls_nextGeneratorNotif = CurTime() + 2
		net.Start( "notificationSlasher" )
		net.WriteTable({"round_notif_error_generator"})
		net.WriteString("cross")
		net.Send(caller)
	end
end

function ENT:OnRemove()
	self:StopSound( "engine_sound" )
end

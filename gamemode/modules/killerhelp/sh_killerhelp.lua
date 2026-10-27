-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-25 16:15:50
-- @Last Modified by:   Hyltaria
-- @Last Modified time: 2026-10-27
--
-- Invisibility helpers (used by the Proxy on slash_subway).
-- The invisible state is stored in the networked bool "sls_invisible".
-- IMPORTANT: GM:ShouldCollide must always return the same result for the same
-- pair of entities. When the state changes we call Entity:CollisionRulesChanged()
-- on both realms, otherwise the physics engine can crash the server.

function SLS_IsInvisible(ent)
	return IsValid(ent) and ent:IsPlayer() and ent:GetNWBool("sls_invisible", false)
end

-- Silent footsteps for invisible players
hook.Add("PlayerFootstep", "CDisableSoundFootStepsUnique", function(ply)
	if SLS_IsInvisible(ply) then
		return true
	end
end)

-- Only one entity of a pair needs the custom collision check: the players.
local function EnableCustomCollision(ent)
	if IsValid(ent) and ent:IsPlayer() then
		ent:SetCustomCollisionCheck(true)

		if CLIENT then
			-- Client side: refresh collision rules when the networked state changes
			ent:SetNWVarProxy("sls_invisible", function(e)
				timer.Simple(0, function()
					if IsValid(e) then e:CollisionRulesChanged() end
				end)
			end)
		end
	end
end
hook.Add("OnEntityCreated", "sls_killerhelp_CustomCollision", function(ent)
	timer.Simple(0, function() EnableCustomCollision(ent) end)
end)

local function EnableAll()
	for _, v in ipairs(player.GetAll()) do
		EnableCustomCollision(v)
	end
end
hook.Add("InitPostEntity", "sls_killerhelp_CustomCollisionInit", EnableAll)
hook.Add("sls_round_PostStart", "sls_killerhelp_CustomCollisionRound", EnableAll)

-- An invisible player goes through doors, players and props (but not the world).
hook.Add("ShouldCollide", "sls_killerhelp_ShouldCollide", function(ent1, ent2)
	if ent1:IsWorld() or ent2:IsWorld() then return end
	if SLS_IsInvisible(ent1) or SLS_IsInvisible(ent2) then
		return false
	end
end)

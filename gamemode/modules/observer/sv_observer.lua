-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-25 16:15:50
-- @Last Modified by:   Garrus2142
-- @Last Modified time: 2017-08-09T15:57:36+02:00

local GM = GM or GAMEMODE

local function SpectatePlayer(ply, target)
	if !IsValid(target) then return end
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(target)
	-- (removed) ply:SetParent(target): parenting a player to another player causes view bugs
	ply:SetPos(target:GetPos())
end

local function SpectateNext(ply)
	if !GM.ROUND.Active then return end

	local survivorsAlive = {}
	local indice

	for _, v in ipairs(GM.ROUND.Survivors) do
		if IsValid(v) and v:Alive() then
			table.insert(survivorsAlive, v)
		end
	end

	indice = table.KeyFromValue(survivorsAlive, ply:GetObserverTarget())
	if !indice then indice = 1 end

	indice = indice + 1
	if indice > #survivorsAlive then
		indice = 1
	end
	SpectatePlayer(ply, survivorsAlive[indice])
end

local function SpectatePrev(ply)
	if !GM.ROUND.Active then return end

	local survivorsAlive = {}
	local indice

	for _, v in ipairs(GM.ROUND.Survivors) do
		if IsValid(v) and v:Alive() then
			table.insert(survivorsAlive, v)
		end
	end

	indice = table.KeyFromValue(survivorsAlive, ply:GetObserverTarget())
	if !indice then indice = 1 end
	indice = indice - 1
	if indice <= 0 then
		indice = #survivorsAlive
	end
	SpectatePlayer(ply, survivorsAlive[indice])
end

local function PlayerDeath( ply )
	-- Start Spectate
	timer.Simple(4, function()
		if !GM.ROUND.Active then return end
		if !IsValid(ply) then return end
		if ply:Team() != TEAM_SURVIVORS then return end

		for _,v in ipairs(GM.ROUND.Survivors) do
			if IsValid(v) and v:Alive() then
				SpectatePlayer(ply, v)
				break
			end
		end
	end)
end
hook.Add("PlayerDeath", "sls_observer_PlayerDeath", PlayerDeath)

local function PostPlayerDeathDisconnect(ply)
	-- Next spectate
	for _, v in ipairs(player.GetAll()) do
		if v:GetObserverTarget() == ply then
			SpectateNext(v)
		end
	end
end
hook.Add("PostPlayerDeath", "sls_observer_PostPlayerDeath", PostPlayerDeathDisconnect)
hook.Add("PlayerDisconnected", "sls_observer_PlayerDisconnected", PostPlayerDeathDisconnect)

local function EndRound()
	for _, v in ipairs(player.GetAll()) do
		if v:GetObserverMode() != OBS_MODE_NONE then
			v:UnSpectate()
			v:SetObserverMode(OBS_MODE_NONE)
			v:SetParent(nil)
		end
	end
end
hook.Add("sls_round_OnTeamWin", "sls_observer_OnTeamWin", EndRound)
hook.Add("sls_round_End", "sls_observer_End", EndRound)
hook.Add("sls_round_PreStart", "sls_observer_PreStart", EndRound)

local function KeyPress( ply, key )
	if ply:Alive() then return end
	if ply:GetObserverMode() == OBS_MODE_NONE then return end

	if key == IN_JUMP then
		ply:SetObserverMode(ply:GetObserverMode() == OBS_MODE_CHASE and OBS_MODE_IN_EYE or OBS_MODE_CHASE)
	elseif key == IN_ATTACK then
		SpectateNext(ply)
	elseif key == IN_ATTACK2 then
		SpectatePrev(ply)
	end
end
hook.Add("KeyPress", "sls_observer_KeyPress", KeyPress)

-- A player who joins during a round spectates an alive survivor.
-- Before: the camera was disabled for EVERYBODY (net.Broadcast) and the loop did not stop.
local function PlayerReady(ply)
	timer.Simple(5, function()
		if !IsValid(ply) or ply:Alive() or !GM.ROUND.Active then return end
		for _, v in ipairs(GM.ROUND.Survivors) do
			if IsValid(v) and v:Alive() then
				net.Start("sls_round_Camera")
					net.WriteBool(false)
				net.Send(ply)
				SpectatePlayer(ply, v)
				break
			end
		end
	end)
end
hook.Add("sls_PlayerReady", "sls_round_PlayerInitialSpawn", PlayerReady)


local function DeadChat(rext,teamOnly,listener,speaker)
	if speaker:IsPlayer() and !speaker:Alive() and listener:Alive() then
		return false
	end
end
hook.Add("PlayerCanSeePlayersChat","sls_observer_chat",DeadChat)

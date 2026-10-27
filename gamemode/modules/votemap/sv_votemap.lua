-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH
-- @Date:   21-Oct-2018
-- @Last Modified by:   Hyltaria
-- @Last Modified time: 2026-10-27

util.AddNetworkString("slash_sendvotedata")
util.AddNetworkString("slash_summitvote")
util.AddNetworkString("slash_openvotemap")
util.AddNetworkString("slash_sendmaplist")

local GM = GAMEMODE or GM

local currentVote = {}
local countVote = {}

local function GetVotableMaps()
	local maps = table.Copy(GM.MAPS)
	table.RemoveByValue(maps, game.GetMap())
	return maps
end

-- Sent when the client is ready (see sls_client_ready in core/rounds/sv_rounds.lua)
local function sendMapList(ply)
	net.Start("slash_sendmaplist")
		net.WriteTable(GetVotableMaps())
	net.Send(ply)
end
hook.Add("sls_PlayerReady", "slash_sendmaplist", sendMapList)

local function isValidChoice(map)
	return map == "extend" or map == "random" or table.HasValue(GetVotableMaps(), map)
end

local function receiveVote(len, ply)
	local map = net.ReadString()
	if map != "" then
		if !isValidChoice(map) then return end
		currentVote[ply] = map
	end

	countVote = {}
	for _, v in ipairs(GetVotableMaps()) do
		countVote[v] = #table.KeysFromValue(currentVote, v)
	end
	countVote["extend"] = #table.KeysFromValue(currentVote, "extend")
	countVote["random"] = #table.KeysFromValue(currentVote, "random")

	net.Start("slash_sendvotedata")
		net.WriteTable(countVote)
	net.Broadcast()
end
net.Receive("slash_summitvote", receiveVote)

local function openVoteMap(ply, button)
	if button == KEY_F2 then
		net.Start("slash_openvotemap")
		net.Send(ply)
	end
end
hook.Add("PlayerButtonDown", "slash_openvotemap", openVoteMap)

-- Called by core/rounds/sv_rounds.lua when the last round is over.
-- Returns "extend", or the name of the next map.
local function GetNextMap()
	local best, bestCount = nil, 0
	for map, count in pairs(countVote) do
		if count > bestCount then
			best, bestCount = map, count
		end
	end
	countVote = {}
	currentVote = {}

	-- Nobody voted (before: table.GetWinningKey returned nil -> Lua error, no map change)
	if !best or best == "random" then
		local maps = GetVotableMaps()
		if #maps == 0 then return "extend" end
		return maps[math.random(#maps)]
	end

	if best == "extend" then
		PrintMessage(HUD_PRINTTALK, "Map extended !")
	end
	return best
end
hook.Add("sls_round_GetNextMap", "sls_votemap_GetNextMap", GetNextMap)

-- Open the vote for everybody at the end of the last round
local function autoOpen()
	if GM.ROUND.Count >= GetConVar("slashers_round_max"):GetInt() then
		net.Start("slash_openvotemap")
		net.Broadcast()
	end
end
hook.Add("sls_round_End", "sls_autoOpen", autoOpen)

local function removeDisconnectVote(ply)
	currentVote[ply] = nil
end
hook.Add("PlayerDisconnected", "sls_remove_disconnectedvote", removeDisconnectVote)

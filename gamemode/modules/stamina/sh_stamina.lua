-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH
-- @Date:   2017-07-26T13:54:42+02:00
-- @Last Modified by:   Garrus2142
-- @Last Modified time: 2017-07-27 18:08:23




sound.Add( {
	name = "Breathing",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "player/breathe.wav"
} )


-----
-----

if SERVER then
	-- The client only tells the server "I start / stop breathing".
	-- The sound name is fixed server side (before, any client could play any sound).
	util.AddNetworkString( "sls_stamina_Breathing" )

	net.Receive( "sls_stamina_Breathing", function( len, ply )
		local state = net.ReadBool()
		if !IsValid(ply) then return end

		if state and ply:Alive() and ply:Team() == TEAM_SURVIVORS then
			if !ply.sls_breathing then
				ply:EmitSound("Breathing")
				ply.sls_breathing = true
			end
		elseif ply.sls_breathing then
			ply:StopSound("Breathing")
			ply.sls_breathing = false
		end
	end )

	local function StopBreathing(ply)
		if IsValid(ply) and ply.sls_breathing then
			ply:StopSound("Breathing")
			ply.sls_breathing = false
		end
	end
	hook.Add("PlayerDeath", "sls_stamina_StopBreathing", StopBreathing)
	hook.Add("PlayerSilentDeath", "sls_stamina_StopBreathingSilent", StopBreathing)
end



------
------
------
if CLIENT then
	local AlreadyJump = false
	local AlreadyBreathing = false
	local GM = GM or GAMEMODE

	-- Only sends a message when the state really changes (before: one message per frame)
	local function SetBreathing(state)
		if AlreadyBreathing == state then return end
		AlreadyBreathing = state
		net.Start("sls_stamina_Breathing")
			net.WriteBool(state)
		net.SendToServer()
	end

	local function RemoveButton(buttons, button)
		return bit.band(buttons, bit.bnot(button))
	end

	local function IsMoving(cmd)
		return cmd:KeyDown(IN_FORWARD) or cmd:KeyDown(IN_BACK) or cmd:KeyDown(IN_MOVELEFT) or cmd:KeyDown(IN_MOVERIGHT)
	end

	function GetClientMove(cmd)
		local ply = LocalPlayer()
		if !IsValid(ply) then return end
		if !GAMEMODE.ROUND.Active || !IsValid(GAMEMODE.ROUND.Killer) || !GAMEMODE.ROUND.Survivors then return end
		if !table.HasValue(GAMEMODE.ROUND.Survivors, ply) then return end

		local class = GAMEMODE.CLASS.Survivors[ply.ClassID]
		if !class or !ply.Stamina or !ply.MaxStamina then return end

		local NewButtons = cmd:GetButtons()
		local Change = FrameTime() * 5

		if !ply:Alive() then
			ply.Stamina = ply.MaxStamina
			SetBreathing(false)
			return
		end

		-- Breathing with hysteresis: starts under 40% of the stamina, stops above 75%
		if ply.Stamina <= ply.MaxStamina * 0.4 then
			SetBreathing(true)
		elseif ply.Stamina >= ply.MaxStamina * 0.75 then
			SetBreathing(false)
		end

		if cmd:KeyDown(IN_JUMP) and ply:OnGround() and !ply:InVehicle() then

			if ply.Stamina <= 5 then
				NewButtons = RemoveButton(NewButtons, IN_JUMP)
			end

			if not AlreadyJump and ply.Stamina >= 5 then
				ply.Stamina = ply.Stamina - (ply.MaxStamina * 1/7)
			end
			AlreadyJump = true

		elseif not cmd:KeyDown(IN_JUMP) then
			AlreadyJump = false
		end

		if cmd:KeyDown(IN_SPEED) and IsMoving(cmd) and (ply:GetVelocity():Length() > 100) and ( ply:OnGround() or ply:WaterLevel() ~= 0 ) and !ply:InVehicle() then

			if ply.Stamina <= 0 then
				NewButtons = RemoveButton(NewButtons, IN_SPEED)
			else
				ply.Stamina = math.Clamp(ply.Stamina - 2 * Change * ply.DecayMul, 0, ply.MaxStamina)
				ply.NextRegen = CurTime() + 2.25
			end
		end

		if ply.NextRegen and ply.NextRegen < CurTime() then
			local isSports = ply.ClassID == CLASS_SURV_SPORTS
			local mul
			if IsMoving(cmd) then
				mul = isSports and 1.5 or 0.5
			else
				mul = isSports and 2 or 1
			end
			ply.Stamina = math.Clamp(ply.Stamina + ( Change * mul * ply.RegenMul ), 0, ply.MaxStamina)
		end

		cmd:SetButtons(NewButtons)
	end

	hook.Add("CreateMove"," Sprint",GetClientMove)

	local function ResetStamina()
		local ply = LocalPlayer()
		AlreadyJump = false
		SetBreathing(false)
		if !IsValid(ply) or ply == GAMEMODE.ROUND.Killer then return end
		local class = GAMEMODE.CLASS.Survivors[ply.ClassID]
		if !class then return end
		ply.Stamina = class.stamina
		ply.MaxStamina = class.stamina
		ply.DecayMul = 0.8
		ply.RegenMul = 1.8

		ply.NextRegen = 0
		ply.WaterTick = 0
	end
	hook.Add("sls_round_PostStart", "sls_stamina_PostStart", ResetStamina)

	-- A function to draw a certain part of a texture
	local function DrawPartialTexturedRect( x, y, w, h, partx, party, partw, parth, texw, texh )
		-- Verify that we recieved all arguments
		if not( x && y && w && h && partx && party && partw && parth && texw && texh ) then
			ErrorNoHalt("surface.DrawPartialTexturedRect: Missing argument!");

			return;
		end;

		-- Get the positions and sizes as percentages / 100
		local percX, percY = partx / texw, party / texh;
		local percW, percH = partw / texw, parth / texh;

		-- Process the data
		local vertexData = {
			{
				x = x,
				y = y,
				u = percX,
				v = percY
			},
			{
				x = x + w,
				y = y,
				u = percX + percW,
				v = percY
			},
			{
				x = x + w,
				y = y + h,
				u = percX + percW,
				v = percY + percH
			},
			{
				x = x,
				y = y + h,
				u = percX,
				v = percY + percH
			}
		};

		surface.DrawPoly( vertexData );
	end;

	local MAT_STAMINA = Material("icons/stamina_bar.png")
	local alpha_stamina = 0
	local function HUDPaint()
		local ply = LocalPlayer()
		local bwide
		local scrW, scrH = ScrW(), ScrH()
		if ply:Team() != TEAM_SURVIVORS || !ply:Alive() then return end
		if !ply.ClassID || !ply.Stamina || !GAMEMODE.ROUND.Active || !GAMEMODE.CLASS.Survivors[ply.ClassID] then return end
		bwide = 256 * ply.Stamina / GAMEMODE.CLASS.Survivors[ply.ClassID].stamina
		if ply.Stamina == GAMEMODE.CLASS.Survivors[ply.ClassID].stamina && alpha_stamina > 0 then
			alpha_stamina = math.max(0, alpha_stamina - 4)
		elseif ply.Stamina < GAMEMODE.CLASS.Survivors[ply.ClassID].stamina && alpha_stamina < 255 then
			alpha_stamina = math.min(alpha_stamina + 4, 255)
		end
		surface.SetDrawColor(Color(150, 150, 150, alpha_stamina))
		surface.SetMaterial(MAT_STAMINA)
		surface.DrawTexturedRect(scrW / 2 - 128, scrH - 48, 256, 32)
		surface.SetDrawColor(Color(255, 255, 255, alpha_stamina))
		surface.SetMaterial(MAT_STAMINA)
		DrawPartialTexturedRect(scrW / 2 - 128, scrH - 48, bwide, 32, 0, 0, bwide, 32, 256, 32)
	end
	hook.Add("HUDPaint", "sls_stamina_HUDPaint", HUDPaint)
end

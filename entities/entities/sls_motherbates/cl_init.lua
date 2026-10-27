-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH
-- @Date:   2017-07-26T13:54:42+02:00
-- @Last modified by:   Guilhem PECH
-- @Last modified time: 15-Apr-2018

include("shared.lua")


local GM = GM or GAMEMODE


GM.oldLevel = null
GM.SoundPlayed = null

ENT.RenderGroup = RENDERGROUP_BOTH

GM.MommyEntity = nil 

function ENT:Initialize()
	GM.MommyEntity = self
end

function ENT:Draw()
	self.Entity:DrawModel()
end

local ICON_MOTHER = Material("icons/icon_mother.png")
local function HUDPaintBackground()
	if LocalPlayer():Team() != TEAM_KILLER || !GM.ROUND.Active || !IsValid(GM.MommyEntity) then return end
	
	local pos = GM.MommyEntity:GetPos():ToScreen()
	local color = Color(255,255,255)
	if GM.oldLevel == 3 then
		color = Color(255,0,0)
	elseif GM.oldLevel == 1 then
		color = Color(0,255,0)
	elseif GM.oldLevel == 2 then 
		color = Color(255, 239, 0)
	else
		color = Color(255, 255, 255)
	end

	surface.SetDrawColor(color)
	surface.SetMaterial(ICON_MOTHER)
	surface.DrawTexturedRect(pos.x - 50, pos.y -100, 64, 64)
end
-- Own hook name: before it had the same name as the Ghostface / Myers HUD hooks and overwrote them
hook.Add("HUDPaintBackground", "sls_motherbates_HUDPaintBackground", HUDPaintBackground)

function ENT:DrawTranslucent()
	if LocalPlayer():IsLineOfSightClear( self.Entity ) and self.Entity:GetPos():Distance( LocalPlayer():GetPos()) < 150 and  LocalPlayer():Team() != TEAM_KILLER   then
		DrawIndicator(self.Entity)
	end
end

function ENT:Think()

end

function ENT:OnRemove()
	if IsValid(GM.SoundPlayed) then
		GM.SoundPlayed:Stop()
	end
	GM.oldLevel = null
	GM.MommyEntity = null
end
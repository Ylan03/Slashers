-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH <Daryl_Winters>
-- @Date:   2017-08-09T14:06:19+02:00
-- @Last Modified by:   Daryl_Winters
-- @Last Modified time: 2017-08-09T14:56:48+02:00

--- Show stuff on objective entity

local function getUseKey()
	local bind = input.LookupBinding("+use", true)
	local cpt = bind and input.GetKeyCode(bind) or KEY_E

	if cpt > KEY_Z then
		if cpt == KEY_ENTER or cpt == KEY_PAD_ENTER then
			return "L"
		else
			return ">"
		end
	else
		return input.GetKeyName( cpt )
	end
end

-- Computed at draw time (before: once at load, the binding was sometimes not available yet)
local usekey = "E"
local nextKeyCheck = 0
function DrawIndicator(ent)
	if nextKeyCheck < CurTime() then
		nextKeyCheck = CurTime() + 5
		usekey = getUseKey() or "E"
	end


	local name = string.Explode( " ", ent.PrintName )[1]
	local description = ent.Information

	local x = ent:GetPos().x + ent:OBBCenter().x			//Get the X position of our player
	local y = ent:GetPos().y	+ ent:OBBCenter().y		//Get the Y position of our player
	local z = ent:GetPos().z	+ ent:OBBCenter().z		//Get the Z position of our player
	local zOffset = 0


	local pos = Vector(x,y,z+zOffset)
	local pos2d = pos:ToScreen()		//Change the 3D vector to a 2D one
	local TitleSize = draw.GetFontHeight( "Bohemian typewriter STITLE" )
	local KeySize = draw.GetFontHeight( "KeyboardFont" )
	-- local usekey = input.LookupKeyBinding( KEY_E )
  cam.Start2D()
  draw.DrawText(name,"Bohemian typewriter STITLE",pos2d.x,pos2d.y,Color(255,0,0,255),TEXT_ALIGN_CENTER)
	draw.DrawText(usekey.."           ","KeyboardFont",pos2d.x  ,pos2d.y + TitleSize + 10,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	draw.DrawText(description,"Bohemian typewriter SA",pos2d.x + 5, pos2d.y + TitleSize + 10 ,Color(255,255,255,255),TEXT_ALIGN_CENTER)
  cam.End2D()
end

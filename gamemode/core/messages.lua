-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-25 16:15:47
-- @Last Modified by:   Garrus2142
-- @Last Modified time: 2017-07-26 14:47:38

local scrW, scrH = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "sls_messages_ScreenSize", function()
	scrW, scrH = ScrW(), ScrH()
end)
local msg_print = {}
local msg_printfade = {}
messages = {}

local function HUDPaint()
	local curtime = CurTime()
	-- Print
	-- Reverse loops: table.remove inside ipairs skipped the next message
	for k = #msg_print, 1, -1 do
		local v = msg_print[k]
		if v.endtime < curtime then
			table.remove(msg_print, k)
			continue
		end

		surface.SetFont(v.font)
		local tw, th = surface.GetTextSize(v.msg)
		surface.SetTextColor(v.color)
		surface.SetTextPos(scrW / 2 - tw / 2, v.ypos - th / 2)
		surface.DrawText(v.msg)
	end

	-- PrintFade
	for k = #msg_printfade, 1, -1 do
		local v = msg_printfade[k]
		if v.endtime < curtime then
			table.remove(msg_printfade, k)
			continue
		end
		if v.starttime > curtime then continue end

		surface.SetFont(v.font)
		local tw, th = surface.GetTextSize(v.msg)
		if curtime < v.starttime + v.fade then
			v.color.a = ((curtime - v.starttime) * 100) * 255 / (v.fade * 100)
		elseif curtime > v.endtime - v.fade then
			v.color.a = ((v.endtime - curtime) * 100) * 255 / (v.fade * 100)
		end
		surface.SetTextColor(v.color)
		surface.SetTextPos(scrW / 2 - tw / 2, v.ypos - th / 2)
		surface.DrawText(v.msg)
	end
end
hook.Add("HUDPaint", "sls_messages_HUDPaint", HUDPaint)

function messages.PrintFade(msg, ypos, delay, fade, color, font)
	table.insert(msg_printfade, {
		msg = msg,
		ypos = ypos,
		starttime = CurTime(),
		endtime = CurTime() + delay,
		fade = fade,
		color = color,
		font = font
	})
end

function messages.Print(msg, delay, color, font)
	table.insert(msg_print, {
		msg = msg,
		ypos = ScrH() / 2, -- before: global "ypos" (nil)
		endtime = CurTime() + delay,
		color = color,
		font = font
	})
end

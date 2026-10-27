-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-25 16:15:46
-- @Last Modified by:   Garrus2142
-- @Last Modified time: 2017-07-26 14:46:14

-- Workshop content sent to the players (list and switch in config.lua).
-- Before: slash_motel and the Season 2 Shared Map Content were missing.
if GM.CONFIG["workshop_download"] then
	for _, id in ipairs(GM.CONFIG["workshop_addons"] or {}) do
		resource.AddWorkshop(id)
	end
end

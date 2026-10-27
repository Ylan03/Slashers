-- Utopia Games - Slashers
--
-- @Author: Guilhem PECH
-- @Date:   2017-07-26T18:34:04+02:00
-- @Last Modified by:   Hyltaria
-- @Last Modified time: 2026-10-27
--
-- Warns the player when the Slashers content is missing.
-- Before: the popup checked the subscription to the Utopia Games items, so it was
-- shown to everybody on a server that provides the content with its own collection.
-- Now the files are checked directly (list in config.lua).

local function IsContentMissing()
	for _, path in ipairs(GAMEMODE.CONFIG["content_check_files"] or {}) do
		if !file.Exists(path, "GAME") then
			return true
		end
	end
	return false
end

local MainFrame

local function OpenContentPopup()
	if IsValid(MainFrame) then MainFrame:Remove() end

	MainFrame = vgui.Create( "DFrame" )
	MainFrame:SetSize( 300, 75 )
	MainFrame:Center()
	MainFrame:SetTitle( "Steam Workshop" )
	MainFrame:SetDraggable( true )
	MainFrame:ShowCloseButton( true )
	MainFrame:MakePopup()

	local InstructionLabel = vgui.Create( "DLabel", MainFrame )
	InstructionLabel:SetPos( 5, 25 )
	InstructionLabel:SetText( GAMEMODE.LANG:GetString("workshop_need_content") )
	InstructionLabel:SizeToContents()

	local workshopID = GAMEMODE.CONFIG["content_workshop_id"] or ""
	if workshopID != "" then
		local WSButton = vgui.Create( "DButton", MainFrame )
		WSButton:SetText( GAMEMODE.LANG:GetString("workshop_get_it") )
		WSButton:SetTextColor( Color( 0, 0, 0 ) )
		WSButton:SetPos( 5, 40 )
		WSButton:SetSize( 100, 30 )
		WSButton.DoClick = function()
			steamworks.ViewFile(workshopID)
			MainFrame:Close()
		end
	end

	local CloseButton = vgui.Create( "DButton", MainFrame )
	CloseButton:SetText( GAMEMODE.LANG:GetString("workshop_no") )
	CloseButton:SetTextColor( Color( 0, 0, 0 ) )
	CloseButton:SetPos( 195, 40 )
	CloseButton:SetSize( 100, 30 )
	CloseButton.DoClick = function()
		MainFrame:Close()
	end
end

function WorkshopDownloadCheck()
	if IsContentMissing() then
		OpenContentPopup()
	end
end

-- Console command kept for debugging: always opens the popup
concommand.Add("OpenWSDL", OpenContentPopup)
net.Receive("slash_WorkShopCheck", WorkshopDownloadCheck)

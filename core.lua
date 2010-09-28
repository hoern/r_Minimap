rMinimap = CreateFrame('Frame', 'rMinimap', Minimap)

if rConfig == nil then
	rConfig = {
		scale = 0.8,
		hide_blizzfeedback = false,
		maxzoom = false,
	}
end

rMinimap:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)

rMinimap:RegisterEvent('ADDON_LOADED')

function rmmSay(str)
	DEFAULT_CHAT_FRAME:AddMessage("|cFF006699rMM|r: " .. str)
end

function rMinimap:StartUp()

	if rConfig.hide_blizzfeedback then
		FeedbackUIButton:Hide()
	end

	if rConfig.maxzoom then
		Minimap:SetZoom(0)
	end

	-- Move, Size, and Square

	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
	Minimap:SetScale(rConfig.scale)
	MinimapBorder:SetTexture(nil)
	Minimap:SetBackdrop({
			bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
			insets = {left = -3, right = -3, top = -3, bottom = -3}
	})
	Minimap:SetBackdropColor(0,0,0,0.63)
	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", UIParent, "BOTTOM", 0, 150)

	-- Hide Buttons

	MinimapBorderTop:Hide()
	MinimapNorthTag:SetAlpha(0)
	MiniMapWorldMapButton:Hide()
	GameTimeFrame:Hide()
	MinimapBorder:Hide()
	MiniMapMailBorder:Hide()
	MiniMapWorldMapButton:UnregisterAllEvents()
	MiniMapTracking:Hide()
	MiniMapTrackingBackground:Hide()
	MiniMapTrackingButtonBorder:SetTexture(nil)
	MiniMapTrackingButton:SetHighlightTexture(nil)
	MiniMapTrackingIconOverlay:SetTexture(nil)
	MiniMapTrackingIcon:Hide()
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()

	-- Move Zone Text

	MinimapZoneText:ClearAllPoints()
	MinimapZoneText:SetPoint("TOP", Minimap, "BOTTOM", 0, -10)
	MinimapZoneText:SetShadowOffset(0, 0)

	-- Move LFG Frame and Dungeon Difficulty

	MiniMapInstanceDifficulty:SetParent(Minimap)
	MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -25, -25)

	MiniMapLFGFrame:SetParent(Minimap)

	local function UpdateLFG()
		MiniMapLFGFrame:ClearAllPoints()
		MiniMapLFGFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0,0)
	end
	hooksecurefunc("MiniMapLFG_UpdateIsShown", UpdateLFG)

	MiniMapLFGFrame:SetHighlightTexture(nil)
	MiniMapLFGFrame:SetAlpha(0.75)
	MiniMapLFGFrameBorder:Hide()
	LFDSearchStatus:SetClampedToScreen(true)

	-- Move Battlefield Frame

	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldBorder:SetTexture(nil)
	BattlegroundShine:Hide()
	MiniMapBattlefieldFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0)

	-- Move Mail

	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailBorder:SetTexture(nil)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 5, -5)


	-- Mouse

	MinimapCluster:EnableMouse(false)
	Minimap:EnableMouseWheel()
	Minimap:SetScript("OnMouseWheel", function(self, direction)
		if direction > 0 then
			MinimapZoomOut:Click()
		else
			MinimapZoomIn:Click()
		end
	end)
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self)
		else
			Minimap_OnClick(self)
		end
	end)

	-- Time Manager

	if(not IsAddOnLoaded('Blizzard_TimeManager')) then
		LoadAddOn('Blizzard_TimeManager')
	end

	TimeManagerClockButton:GetRegions():Hide()
	TimeManagerClockButton:SetSize(40, 14)
	TimeManagerClockTicker:SetPoint('CENTER', TimeManagerClockButton)
	TimeManagerClockTicker:SetShadowOffset(0, 0)
end

function rMinimap:ADDON_LOADED(me)
	if me ~= "r_Minimap" then return end
	self:StartUp()
end

SLASH_RMM1 = "/rismm"
SLASH_RMM2 = "/rmm"

SlashCmdList["RMM"] = function(str)
	local switch, message = str:match("^(%S*)%s*(.-)$");
	local cmd = string.lower(switch)
	local msg = string.lower(message)

	if cmd == "bf" then
		if rConfig.hide_blizzfeedback then
			FeedbackUIButton:Show()
			rmmSay("Blizzard Feeback UI Button Now Shown!")
		else
			FeedbackUIButton:Hide()
			rmmSay("Blizzard Feeback UI Button Now Hidden!")
		end
		rConfig.hide_blizzfeedback = not rConfig.hide_blizzfeedback

	elseif cmd == "scale" then
		scale = tonumber(msg)
		if scale > 1 then scale = 1 end
		Minimap:SetScale(scale)
		rConfig.scale = scale

	elseif cmd == "maxzoom" then
		rConfig.maxzoom = not rConfig.maxzoom
		rmmSay("Minimap maximum zoom out on startup: " .. tostring(rConfig.maxzoom))

	-- elseif cmd == "lock" then
	-- 	if rConfig.locked then
	-- 		rmmSay("unlocked, use /rmm lock to lock again")
	-- 		rConfig.locked = false
	-- 	else
	-- 		rmmSay("locked, use /rmm lock to make movable again")
	-- 		rConfig.locked = true
	-- 	end
	end
end
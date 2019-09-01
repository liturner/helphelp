HelpHelp = {}
HelpHelp.Globals = {}
HelpHelp.Globals.previousTime = 0
HelpHelp.Globals.previousHealth = 0	-- Health in %
HelpHelp.Globals.PLAYER_GUID = UnitGUID("player")

function HelpHelp.OnLoad(self)
	-- HelpHelp.MainFrame = CreateFrame('FRAME', 'HelpHelpOptionsPanel', UIParent)
	self:RegisterEvent('ADDON_LOADED')
	self:RegisterEvent('UNIT_HEALTH')
end

function HelpHelp.OnEvent(self, event, ...) 
	-- Initialise the Addon, migrate DB if neededetc
	if event == "UNIT_HEALTH" then HelpHelp.OnUnitHealth(self, unpack({...})) 		
	elseif(event == "ADDON_LOADED") then HelpHelp.OnAddonLoaded(self, unpack({...})) 
	end
end





function HelpHelp.OnUnitHealth(self, UnitID, ...)
	if UnitGUID("UnitID") == HelpHelp.Globals.PLAYER_GUID then
		-- print("Player Health Change")
		
		-- Collect the info we are going to need
		currentHealth = UnitHealth("player")
		maxHealth = UnitHealthMax("player")
		percentHealth = currentHealth / maxHealth
		currentTime = GetTime()
		deltaTime = currentTime - HelpHelp.Globals.previousTime 				-- In Milliseconds
		deltaHealth = percentHealth - HelpHelp.Globals.previousHealth		-- In Percent
		changeVelocity = (deltaHealth / deltaTime) * 1000	-- Health change per second (from only this hit)
					
		-- print("% deltaHealth: "..deltaHealth)
		-- print("% deltaTime: "..deltaTime)
		-- print("% changeVelocity: "..changeVelocity)
		
		-- Early out if regaining health
		if changeVelocity > 0 then
			return
		end
		
		-- The main check to see if I should yell
		if percentHealth < HelpHelp_Database["Settings"]["HealthThreshold"] then
			SendChatMessage("Help Help!", "YELL", DEFAULT_CHAT_FRAME.editBox.languageID) --, HelpHelp_Database["Settings"]["Language"])
		end
		
		-- Store the current data for use in the next event
		HelpHelp.Globals.previousTime = currentTime
		HelpHelp.Globals.previousHealth = percentHealth
	end
end

function HelpHelp.OnAddonLoaded(self, name, ...)
	if name == "HelpHelp" then

		-- Make sure we have an initialised settings database
		if HelpHelp_Database == nil then
			HelpHelp_Database = { AddonName = 'HelpHelp', SchemaVersion = 1, Settings = { Message = "Help Help!", HealthThreshold = 0.2, Language = "DWARVEN" } }
		end

		-- The "Main" panel is also the settings UI
		self.name = "Help Help!"	
		self.refresh = function (self) HelpHelp.OnOptionRefresh(self); end;
		self.okay = function (self) HelpHelp.OK_Clicked(self); end;
		self.cancel = function (self) HelpHelp.Cancel_Clicked(self); end;
		self.default = function (self) HelpHelp.Default_Clicked(self); end;
		
		
		HelpHelp.SearchInputBox = CreateFrame("EditBox", "AdventureJournal_LootFrameInputBox", self, "InputBoxTemplate")
		HelpHelp.SearchInputBox:SetFontObject(ChatFontSmall)
		HelpHelp.SearchInputBox:SetPoint("TOPLEFT", 90, -62)
		HelpHelp.SearchInputBox:SetSize(250, 24)
		HelpHelp.SearchInputBox:SetText("Search items")
		HelpHelp.SearchInputBox:SetFrameStrata("DIALOG")
		HelpHelp.SearchInputBox:SetAutoFocus(false)
		
		
		
		
		
		
		
		InterfaceOptions_AddCategory(self)
		
		SLASH_HELPHELP1 = "/helphelp"
		
		SlashCmdList["HELPHELP"] = function(msg)
		  InterfaceOptionsFrame_OpenToCategory(self)
		end
		
			
		-- Initial the "previous" variables so that we do not need a safety check in the health event
		currentHealth = UnitHealth("player")
		maxHealth = UnitHealthMax("player")
		previousHealth = currentHealth / maxHealth
		previousTime = GetTime()	

		self:UnregisterEvent("ADDON_LOADED")
	end
end




-- Options UI Functions
function HelpHelp.OK_Clicked(self)
	HelpHelp_Database.Settings.HealthThreshold = tonumber(HelpHelp_HealthThresholdSlider:GetValue())
	print("1")
	HelpHelp_Database.Settings.Message = HelpHelp_MessageEditBox:GetText()
	print("2")
end

function HelpHelp.Cancel_Clicked(self)
  
end

function HelpHelp.Default_Clicked(self)
	HelpHelp_Database.Settings.HealthThreshold = 0.2
	HelpHelp_Database.Settings.Message = "Help Help!"
end

function HelpHelp.OnOptionRefresh(self)
	-- Handle settings values for the UI-SliderBar-Button-Horizontal
	print(HelpHelp_Database.Settings.Message)
	print("Refresh")
	HelpHelp_HealthThresholdSlider:SetValue(HelpHelp_Database.Settings.HealthThreshold)
	-- HelpHelp_MessageEditBox:ClearFocus()
	HelpHelp_MessageEditBox:SetText(HelpHelp_Database.Settings.Message)
	-- HelpHelp_MessageEditBox:SetFrameStrata("DIALOG")
	-- HelpHelp_MessageEditBox:SetAutoFocus(false)
	print("Refresh End")
end
HelpHelp = {}
HelpHelp.Globals = {}
HelpHelp.Globals.previousTime = 0
HelpHelp.Globals.previousShout = 0
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


-- Game Events
function HelpHelp.OnUnitHealth(self, UnitID, ...)
	if UnitGUID(UnitID) == HelpHelp.Globals.PLAYER_GUID then
		-- Collect the info we are going to need
		currentHealth = UnitHealth("player")
		maxHealth = UnitHealthMax("player")
		percentHealth = currentHealth / maxHealth
		currentTime = GetTime()
		deltaTime = currentTime - HelpHelp.Globals.previousTime 			-- In Milliseconds
		deltaHealth = percentHealth - HelpHelp.Globals.previousHealth		-- In Percent
		changeVelocity = (deltaHealth / deltaTime) * 1000					-- Health change per second (from only this hit)
		timeSinceLastShout = currentTime - HelpHelp.Globals.previousShout	-- In Milliseconds
		
		-- Store the current data for use in the next event
		HelpHelp.Globals.previousTime = currentTime
		HelpHelp.Globals.previousHealth = percentHealth
							
		-- Early out if regaining health or shouted recently
		if changeVelocity < 0 and timeSinceLastShout > 10000 then
			-- The main check to see if I should yell
			if percentHealth < HelpHelp_Database.Settings.HealthThreshold then
				SendChatMessage(HelpHelp_Database.Settings.Message, "YELL", DEFAULT_CHAT_FRAME.editBox.languageID) --, HelpHelp_Database["Settings"]["Language"])
				HelpHelp.Globals.previousShout = currentTime
			end
		end
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
	print("healthSlider: "..HelpHelp_HealthThresholdSlider:GetValue())
	HelpHelp_Database.Settings.HealthThreshold = tonumber(HelpHelp_HealthThresholdSlider:GetValue())
	print("healthThreshold: "..HelpHelp_Database.Settings.HealthThreshold)
	HelpHelp_Database.Settings.Message = HelpHelp_MessageEditBox:GetText()
end

function HelpHelp.Cancel_Clicked(self)
  
end

function HelpHelp.Default_Clicked(self)
	HelpHelp_Database.Settings.HealthThreshold = 0.2
	HelpHelp_Database.Settings.Message = "Help Help!"
end

function HelpHelp.OnOptionRefresh(self)
	print("healthThreshold: "..HelpHelp_Database.Settings.HealthThreshold)
	HelpHelp_HealthThresholdSlider:SetValue(HelpHelp_Database.Settings.HealthThreshold)
	HelpHelp_MessageEditBox:SetText(HelpHelp_Database.Settings.Message)
	HelpHelp_MessageEditBox:SetCursorPosition(0)
end
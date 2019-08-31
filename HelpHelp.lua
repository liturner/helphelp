local name, HelpHelp = ...
local previousTime
local previousHealth	-- Health in %

function HelpHelp.OnEvent(self, event, ...) 
	-- Initialise the Addon, migrate DB if neededetc
	if event == "ADDON_LOADED" and ... == "HelpHelp" then		
		-- Make sure we have an initialised settings database
		if HelpHelp_Database == nil then
			HelpHelp_Database = { AddonName = 'HelpHelp', SchemaVersion = 1, Settings = { HealthThreshold = 0.2, Language = "DWARVEN" } }
		end

		-- Initial the "previous" variables so that we do not need a safety check in the health event
		currentHealth = UnitHealth("player")
		maxHealth = UnitHealthMax("player")
		previousHealth = currentHealth / maxHealth
		previousTime = GetTime()

		-- Handle settings values for the UI-SliderBar-Button-Horizontal
		HelpHelp.MainFrame.HealthThreshold:SetValue(HelpHelp_Database["Settings"]["HealthThreshold"])

		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "UNIT_HEALTH" then
		UnitID = ...
		
		if UnitID == "player" then
			print("Player Health Change")
			
			-- Collect the info we are going to need
			currentHealth = UnitHealth("player")
			maxHealth = UnitHealthMax("player")
			percentHealth = currentHealth / maxHealth
			currentTime = GetTime()
			deltaTime = currentTime - previousTime 				-- In Milliseconds
			deltaHealth = percentHealth - previousHealth		-- In Percent
			changeVelocity = (deltaHealth / deltaTime) * 1000	-- Health change per second (from only this hit)
						
			print("% deltaHealth: "..deltaHealth)
			print("% deltaTime: "..deltaTime)
			print("% changeVelocity: "..changeVelocity)
			
			-- Early out if regaining health
			if changeVelocity > 0 then
				return
			end
			
			-- The main check to see if I should yell
			if percentHealth < HelpHelp_Database["Settings"]["HealthThreshold"] then
				SendChatMessage("Help Help!", "YELL") --, HelpHelp_Database["Settings"]["Language"])
			end
			
			-- Store the current data for use in the next event
			previousTime = currentTime
			previousHealth = percentHealth
		end
	end
end

HelpHelp.MainFrame = CreateFrame('FRAME', 'HelpHelpOptionsPanel', UIParent)
HelpHelp.MainFrame.name = "Help Help!";
InterfaceOptions_AddCategory(HelpHelp.MainFrame);
HelpHelp.MainFrame:RegisterEvent('ADDON_LOADED')
HelpHelp.MainFrame:RegisterEvent('UNIT_HEALTH')
HelpHelp.MainFrame:SetScript('OnEvent', HelpHelp.OnEvent)



-- Setup the options panel
-- add a title
HelpHelp.MainFrame.Title = HelpHelp.MainFrame:CreateFontString("HelpHelpOptionsPanelTitle", "OVERLAY", "GameFontNormalLarge")
HelpHelp.MainFrame.Title:SetPoint("TOPLEFT", 16, -16)
HelpHelp.MainFrame.Title:SetText("Help Help!")

-- about
HelpHelp.MainFrame.About = HelpHelp.MainFrame:CreateFontString('HelpHelpOptionsPanelAbout', 'OVERLAY', 'SystemFont_Small')
HelpHelp.MainFrame.About:SetPoint('TOPLEFT', 16, -30)
HelpHelp.MainFrame.About:SetSize(580, 50)
HelpHelp.MainFrame.About:SetJustifyH('LEFT')
HelpHelp.MainFrame.About:SetText('"Help Help!" will automatically yell for help when your health drops too low. Aimed at the Role Play community, you can configure what language and message you yell out!')

-- Alert level slider
HelpHelp.MainFrame.HealthThreshold = CreateFrame("Slider", "HelpHelpHealthThresholdSlider", HelpHelp.MainFrame, "OptionsSliderTemplate")
HelpHelp.MainFrame.HealthThreshold:SetSize(125, 20)
HelpHelp.MainFrame.HealthThreshold:SetOrientation('HORIZONTAL')
HelpHelp.MainFrame.HealthThreshold:SetPoint('TOPLEFT', 26, -95)
HelpHelp.MainFrame.HealthThreshold:SetMinMaxValues(0, 1)
HelpHelp.MainFrame.HealthThreshold:SetValueStep(0.1)
getglobal(HelpHelp.MainFrame.HealthThreshold:GetName()..'Low'):SetText('0%')
getglobal(HelpHelp.MainFrame.HealthThreshold:GetName()..'High'):SetText('100%')
getglobal(HelpHelp.MainFrame.HealthThreshold:GetName()..'Text'):SetText('Health Threshold')

HelpHelp.MainFrame.HealthThreshold:SetScript('OnValueChanged', function(self) 
	HelpHelp_Database["Settings"]["HealthThreshold"] = tonumber(self:GetValue())
end)

-- Language Selector
HelpHelp.MainFrame.Language = CreateFrame("Button", "HelpHelpLanguageSelection", HelpHelp.MainFrame)
HelpHelp.MainFrame.Language:SetPoint('TOPLEFT', 16, -30)
HelpHelp.MainFrame.Language:SetSize(580, 50)


HelpHelp.MainFrame.Language:SetScript('OnLoad', function(self) 
	print("On Drop Down Load")
end)








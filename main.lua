version = "00010"
Listening_EventFrame = nil

print( version )


-- Look for a ChatFrame called "SS Log" or default to the default frame
logChatFrame = DEFAULT_CHAT_FRAME


-- Make our frame for event registration
local loaded = false
local loggedIn = false


-- build continent lookup map
--local k, v
--local continentNames = { GetMapContinents() }
--local continentMap = {}
--
--for k, v in pairs( continentNames ) do
--	continentMap[k] = v
--	logChatFrame:AddMessage( "Continent[" .. k .. "]: " .. continentNames[k] )
--end

local continentMap = {}
continentMap[-1] = "Twisting Nether"
continentMap[0] = "Null Space"
continentMap[1] = "Kalimdor"
continentMap[2] = "Eastern Kingdoms"
continentMap[3] = "Outland"
continentMap[4] = "Northrend"
continentMap[5] = "Maelstrom"
continentMap[6] = "Pandaria"
continentMap[7] = "Draenor"
continentMap[8] = "Broken Isles"



--for i = 0, 7 do
-- 	logChatFrame:AddMessage( "Continent[" .. i .. "]: " .. continentNames[i] )
--end
-- logChatFrame:AddMessage( "Continent[" .. 0 .. "]: " .. continentNames[0] )

Listening_EventFrame = CreateFrame( "Frame" )

-- Wait to be loaded
Listening_EventFrame:RegisterEvent( "ADDON_LOADED" )
-- Listening_EventFrame:RegisterEvent( "UPDATE_CHAT_WINDOWS" )





Listening_EventFrame:SetScript( "OnEvent",
	function( self, event, ... )
--logChatFrame:AddMessage( "Event: |cFFFF0000" .. event .. "|r Time: |cFF00FF00" .. date( "%c", GetServerTime() ) .. "|r" )

local prettyLoaded = loaded and "Yes" or "No"
--logChatFrame:AddMessage( "loaded " .. prettyLoaded )

		if ( loaded == false ) then
			if ( event == "ADDON_LOADED") then
				local addonName = ...

				if ( addonName == "SoucaStats" ) then
					finishInit()
					loaded = true
				end
			end
		else
			local mapX, mapY = GetPlayerMapPosition( "player" )
			local continent = GetCurrentMapContinent() .. "-" .. continentMap[GetCurrentMapContinent()]
			local zoneName = GetRealZoneText() or "Zone"
			local subZoneName = GetSubZoneText() or "Sub Zone"
			local serverTime = GetServerTime()
			local prettyTime = date( "%c", serverTime )
			local onTaxi = UnitOnTaxi( "player" ) and "Yes" or "No"
			
			local logHeader

			if ( loggedIn == true ) then
				logHeader = "|cFFFF0000" .. event .. "|r - Time: >" .. serverTime ..
						"< P Time: >" .. prettyTime .. "< Lvl: >" .. UnitLevel( "player" ) .. "< XP: >" .. UnitXP( "player" ) ..
						"< Lvl XP: >" .. UnitXPMax( "player" ) .. "< Continent: >" .. continent .. "< Zone: >" ..
						zoneName .. "::" .. subZoneName .. "< Loc: (" ..
						mapX .. "," .. mapY .. ") Taxi: >" .. onTaxi .. "<"
			else
				logHeader = "|cFFFF0000" .. event .. "|r - Time: >" .. serverTime ..
						"< P Time: >" .. prettyTime .. "<"
			end

						
						
			if (	event == "PLAYER_ALIVE" or
					event == "PLAYER_DEAD" or
					event == "PLAYER_UNGHOST" or
					event == "PLAYER_CAMPING" ) then			
				local logEntry = logHeader					

				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )

				RequestTimePlayed()


			elseif ( event == "PLAYER_LEVEL_UP" ) then
				local newLevel = ...
				
				local logEntry = logHeader .. " ### |cFF0000FFNew Lvl: >" .. newLevel .. "<|r"

				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry )

				RequestTimePlayed()


			elseif ( event == "TIME_PLAYED_MSG" ) then
				local totalTime, levelTime = ...

				local logEntry = logHeader .. " ### |cFF0099FFPlayed: >" .. totalTime .. "< Lvl Played: >" .. levelTime .. "<|r"

				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )


			elseif ( event == "QUEST_ACCEPTED" ) then
				local questSlot, questId = ...		

				local logEntry = logHeader .. " ### |cFF0000FFQuest Slot: >" .. questSlot ..
						"< Quest ID: >" .. questId .. "<|r"

				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )
				
				RequestTimePlayed()
			

			elseif ( event == "QUEST_REMOVED" ) then
				local questId = ...		

				local logEntry = logHeader .. " ### |cFF0000FFQuest ID: >" .. questId .. "<|r"			

				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )

				RequestTimePlayed()


			elseif ( event == "QUEST_TURNED_IN" ) then
				local questId, questXP, questCopper = ...		

				local logEntry = logHeader .. " ### |cFF0000FFQuest ID: >" .. questId .. "< QuestXP: >" .. questXP ..
						"< QuestCopper: >" .. questCopper .. "<|r"			

				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )

				RequestTimePlayed()


			elseif ( event == "PLAYER_FLAGS_CHANGED" ) then		
				local unit = ...
				
				if ( unit == "player" ) then
					local afkState = UnitIsAFK( "player" ) and "Yes" or "No"

					local logEntry = logHeader .. " ### |cFF0000FFAFK: >" .. afkState .. "<|r"			

					table.insert( SSEventLog.logs, logEntry )
					logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )
				end
				-- RequestTimePlayed()


			elseif ( event == "UPDATE_CHAT_WINDOWS" ) then		
				updateLoggingChatWindow()
				local logEntry = logHeader					

				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )


			elseif ( event == "PLAYER_LOGIN" ) then		
				local logEntry = logHeader					
				loggedIn = true

				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )


			elseif ( event == "PLAYER_LOGOUT" ) then		
				local logEntry = logHeader					
				loggedIn = false
				
				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )


			-- Generic log entries go here
			elseif ( 	event == "UNIT_QUEST_LOG_CHANGED" or
						event == "ZONE_CHANGED_NEW_AREA" or
						event == "ZONE_CHANGED" ) then		

				local logEntry = logHeader		

				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )	

			end

		end 
		
	end
	)


function updateLoggingChatWindow()
	for i = 1, NUM_CHAT_WINDOWS do
	 	if GetChatWindowInfo( i ) == "SS Log" then
			logChatFrame = _G["ChatFrame" .. i]
			logChatFrame:AddMessage( "Using SS Log frame" )
			break
		end
	end
end


function finishInit()
	-- Start logging to the preffered chat pane
	-- updateLoggingChatWindow()

	-- Setup SavedVariables table
	logChatFrame:AddMessage( "SSEventLog Type: " .. type( SSEventLog ) )

	if type( SSEventLog ) ~= "table" then  
		SSEventLog = {}
		logChatFrame:AddMessage( "SSEventLog Created" )
	else
		logChatFrame:AddMessage( "SSEventLog Loaded" )
	end

	logChatFrame:AddMessage( "SSEventLog.logs Type: " .. type( SSEventLog.logs ) )

	if type( SSEventLog.logs ) ~= "table" then
		SSEventLog.logs = {}
		logChatFrame:AddMessage( "SSEventLog.logs created" )
	end


	-- Log Version
	local serverTime = GetServerTime()
	local prettyTime = date( "%c", serverTime )
	local factionGroup, factionName = UnitFactionGroup( "player" )
	local charSex = "U"
	local unitSex = UnitSex( "player" )

	if ( unitSex == 2 ) then charSex = "M"
	elseif ( unitSex == 3 ) then charSex = "F"
	end

	local logEntry = "|cFFFF0000SS_INFO_VERSION|r - Time: >" .. serverTime .. "< P Time: >" .. prettyTime ..
						"< Version: >" .. version .. "< Char: >" .. UnitName( "player" ) .. "< Realm: >" ..
						GetRealmName() .. "< Class: >" .. UnitClass( "player" ) .. "< Race: >" .. UnitRace( "player" ) ..
						"< Faction: >" .. factionGroup .. "< Sex: >" .. charSex .. "<"

	table.insert( SSEventLog, logEntry )
	logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )

	-- Get rid of the addon event first
	Listening_EventFrame:UnregisterEvent( "ADDON_LOADED" )


	-- Register Events

	-- UI Events
	Listening_EventFrame:RegisterEvent( "UPDATE_CHAT_WINDOWS" )

	-- Player status events
	Listening_EventFrame:RegisterEvent( "PLAYER_ALIVE" )
	Listening_EventFrame:RegisterEvent( "PLAYER_DEAD" )
	Listening_EventFrame:RegisterEvent( "PLAYER_UNGHOST" )
	Listening_EventFrame:RegisterEvent( "PLAYER_CAMPING" )

	-- Session events
	Listening_EventFrame:RegisterEvent( "PLAYER_LOGIN" )
	Listening_EventFrame:RegisterEvent( "PLAYER_LOGOUT" )

	-- Leveling events
	Listening_EventFrame:RegisterEvent( "PLAYER_LEVEL_UP" )

	-- Server query response events
	Listening_EventFrame:RegisterEvent( "TIME_PLAYED_MSG" )

	-- Quest events
	Listening_EventFrame:RegisterEvent( "QUEST_ACCEPTED" )
	Listening_EventFrame:RegisterEvent( "QUEST_REMOVED" )
	Listening_EventFrame:RegisterEvent( "QUEST_TURNED_IN" )
	-- Listening_EventFrame:RegisterEvent( "UNIT_QUEST_LOG_CHANGED" )

	-- Player status events
	Listening_EventFrame:RegisterEvent( "PLAYER_FLAGS_CHANGED" )

	-- Location events
	Listening_EventFrame:RegisterEvent( "ZONE_CHANGED" )
	Listening_EventFrame:RegisterEvent( "ZONE_CHANGED_NEW_AREA" )
end

-- UI_INFO_MESSAGE
-- Arg1: 287 ??
-- Arg2: "Lynx Collar: 8/8"

-- UI_INFO_MESSAGE
-- Arg1: 284 ??
-- Arg2: "Objective Complete"
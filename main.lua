local version = "00008"
print( version )


-- Look for a ChatFrame called "SS Log" or default to the default frame
local logChatFrame = DEFAULT_CHAT_FRAME

for i = 1, NUM_CHAT_WINDOWS do
 	if GetChatWindowInfo( i ) == "SS Log" then
		logChatFrame = _G["ChatFrame" .. i]
		logChatFrame:AddMessage( "Using SS Log frame" )
		break
	end
end


-- Setup SavedVariables table
if type( SSEventLog ) ~= "table" then  
	SSEventLog = {}
	logChatFrame:AddMessage( "SSEventLog Created" )
else
	logChatFrame:AddMessage( "SSEventLog Loaded" )
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


-- Make our frame for event registration
local Listening_EventFrame = CreateFrame( "Frame" )

-- Register Events
Listening_EventFrame:RegisterEvent( "PLAYER_ALIVE" )
Listening_EventFrame:RegisterEvent( "PLAYER_DEAD" )
Listening_EventFrame:RegisterEvent( "PLAYER_UNGHOST" )
Listening_EventFrame:RegisterEvent( "PLAYER_CAMPING" )

Listening_EventFrame:RegisterEvent( "PLAYER_LOGIN" )
Listening_EventFrame:RegisterEvent( "PLAYER_LOGOUT" )

Listening_EventFrame:RegisterEvent( "PLAYER_LEVEL_UP" )

Listening_EventFrame:RegisterEvent( "TIME_PLAYED_MSG" )

Listening_EventFrame:RegisterEvent( "QUEST_ACCEPTED" )
Listening_EventFrame:RegisterEvent( "QUEST_REMOVED" )
Listening_EventFrame:RegisterEvent( "QUEST_TURNED_IN" )
-- Listening_EventFrame:RegisterEvent( "UNIT_QUEST_LOG_CHANGED" )

Listening_EventFrame:RegisterEvent( "PLAYER_FLAGS_CHANGED" )

Listening_EventFrame:RegisterEvent( "ZONE_CHANGED" )
Listening_EventFrame:RegisterEvent( "ZONE_CHANGED_NEW_AREA" )



Listening_EventFrame:SetScript( "OnEvent",
	function( self, event, ... )
		local mapX, mapY = GetPlayerMapPosition( "player" )
		local continent = GetCurrentMapContinent()
		local zoneName = GetRealZoneText() or "Zone"
		local subZoneName = GetSubZoneText() or "Sub Zone"
		local serverTime = GetServerTime()
		local prettyTime = date( "%c", serverTime )
		local onTaxi = UnitOnTaxi( "player" ) and "Yes" or "No"
		
		local logHeader = "|cFFFF0000" .. event .. "|r - Time: >" .. serverTime ..
					"< P Time: >" .. prettyTime .. "< Lvl: >" .. UnitLevel( "player" ) .. "< XP: >" .. UnitXP( "player" ) ..
					"< Lvl XP: >" .. UnitXPMax( "player" ) .. "< Continent: >" .. continent .. "< Zone: >" ..
					zoneName .. "::" .. subZoneName .. "< Loc: (" ..
					mapX .. "," .. mapY .. ") Taxi: >" .. onTaxi .. "<"

					
					
		if (	event == "PLAYER_ALIVE" or
				event == "PLAYER_DEAD" or
				event == "PLAYER_UNGHOST" or
				event == "PLAYER_CAMPING" ) then			
			local logEntry = logHeader					

			table.insert( SSEventLog, logEntry )
			logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )

			RequestTimePlayed()


		elseif ( event == "PLAYER_LEVEL_UP" ) then
			local newLevel = ...
			
			local logEntry = logHeader .. " ### New Lvl: >" .. newLevel .. "<"

			table.insert( SSEventLog, logEntry )
			logChatFrame:AddMessage( "Souca Stats: " .. logEntry )

			RequestTimePlayed()


		elseif ( event == "TIME_PLAYED_MSG" ) then
			local totalTime, levelTime = ...

			local logEntry = logHeader .. " ### Played: >" .. totalTime .. "< Lvl Played: >" .. levelTime .. "<"

			table.insert( SSEventLog, logEntry )
			logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )


		elseif ( event == "QUEST_ACCEPTED" ) then
			local questSlot, questId = ...		

			local logEntry = logHeader .. " ### Quest Slot: >" .. questSlot ..
					"< Quest ID: >" .. questId .. "<"

			table.insert( SSEventLog, logEntry )
			logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )
			
			RequestTimePlayed()
		

		elseif ( event == "QUEST_REMOVED" ) then
			local questId = ...		

			local logEntry = logHeader .. " ### Quest ID: >" .. questId .. "<"			

			table.insert( SSEventLog, logEntry )
			logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )

			RequestTimePlayed()


		elseif ( event == "QUEST_TURNED_IN" ) then
			local questId, questXP, questCopper = ...		

			local logEntry = logHeader .. " ### Quest ID: >" .. questId .. "< QuestXP: >" .. questXP ..
					"< QuestCopper: >" .. questCopper .. "<"			

			table.insert( SSEventLog, logEntry )
			logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )

			RequestTimePlayed()


		elseif ( event == "PLAYER_FLAGS_CHANGED" ) then		
			local unit = ...
			
			if ( unit == "player" ) then
				local afkState = UnitIsAFK( "player" ) and "Yes" or "No"

				local logEntry = logHeader .. " ### AFK: >" .. afkState .. "<"			

				table.insert( SSEventLog, logEntry )
				logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )
			end
			-- RequestTimePlayed()

		-- Generic log entries go here
		elseif ( 	event == "PLAYER_LOGIN" or
					event == "PLAYER_LOGOUT" or
					event == "UNIT_QUEST_LOG_CHANGED" or
					event == "ZONE_CHANGED_NEW_AREA" or
					event == "ZONE_CHANGED" ) then		

			local logEntry = logHeader		

			table.insert( SSEventLog, logEntry )
			logChatFrame:AddMessage( "Souca Stats: " .. logEntry  )	

		end
		
	end
	)



-- UI_INFO_MESSAGE
-- Arg1: 287 ??
-- Arg2: "Lynx Collar: 8/8"

-- UI_INFO_MESSAGE
-- Arg1: 284 ??
-- Arg2: "Objective Complete"
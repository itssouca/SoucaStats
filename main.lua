version = "00018"
Listening_EventFrame = nil

print( version )


-- Look for a ChatFrame called "SS Log" or default to the default frame
logChatFrame = DEFAULT_CHAT_FRAME


-- Make our frame for event registration
local loaded = false
local loggedIn = false

local playedHeartbeatElapsed = 0
local locationHeartbeatElapsed = 0

local playedHeartbeatInterval = 900 -- 15 minutes
local locationHeartbeatInterval = 30 -- 30 seconds


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

Listening_EventFrame = CreateFrame( "Frame", "listeningFrame" )
Debugging_EventFrame = CreateFrame( "Frame", "debuggingFrame" )

-- Wait to be loaded
Listening_EventFrame:RegisterEvent( "ADDON_LOADED" )
-- Listening_EventFrame:RegisterEvent( "UPDATE_CHAT_WINDOWS" )






function eventHandler( self, event, ... )
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
		local continentID = GetCurrentMapContinent()
		local continent = continentID .. "-" .. continentMap[continentID]
		local zoneName = GetRealZoneText() or "Zone"
		local subZoneName = GetSubZoneText() or "Sub Zone"
		local serverTime = GetServerTime()
		local prettyTime = date( "%c", serverTime )
		local onTaxi = UnitOnTaxi( "player" ) and "Y" or "N"
		local unitLevel = UnitLevel( "player" )
		
		local logHeader
		local displayHeader

		if ( loggedIn == true ) then
			logHeader = event .. "|" .. serverTime .. "|" .. unitLevel .. "|" ..
					UnitXP( "player" ) .. "|" .. UnitXPMax( "player" ) .. "|" .. continentID ..
					"|" .. zoneName .. "|" .. subZoneName .. "|" ..
					mapX .. "," .. mapY .. "|" .. onTaxi
			displayHeader = "|cFFFF0000" .. event .. "|r - |cFF0099FFTime: |cFFFF7633>|cFFDD33FF" .. serverTime ..
					"|cFFFF7633<|cFF0099FF P Time: |cFFFF7633>|cFFDD33FF" .. prettyTime .. "|cFFFF7633<|cFF0099FF Lvl: |cFFFF7633>|cFFDD33FF" ..
					unitLevel .. "|cFFFF7633<|cFF0099FF XP: |cFFFF7633>|cFFDD33FF" .. UnitXP( "player" ) ..
					"|cFFFF7633<|cFF0099FF Lvl XP: |cFFFF7633>|cFFDD33FF" .. UnitXPMax( "player" ) ..
					"|cFFFF7633<|cFF0099FF Continent: |cFFFF7633>|cFFDD33FF" .. continent .. "|cFFFF7633<|cFF0099FF Zone: |cFFFF7633>|cFFDD33FF" ..
					zoneName .. "|cFFFF7633::|cFFDD33FF" .. subZoneName .. "|cFFFF7633<|cFF0099FF Loc: |cFFFF7633(|cFFDD33FF" ..
					mapX .. "|cFFFF7633,|cFFDD33FF" .. mapY .. "|cFFFF7633)|cFF0099FF Taxi: |cFFFF7633>|cFFDD33FF" .. onTaxi .. "|cFFFF7633<|r"
		else
			logHeader = event .. "|" .. serverTime
			displayHeader = "|cFFFF0000" .. event .. "|r - |cFF0099FFTime: |cFFFF7633>|cFFDD33FF" .. serverTime ..
					"|cFFFF7633<|cFF0099FF P Time: |cFFFF7633>|cFFDD33FF" .. prettyTime .. "|cFFFF7633<|r"
		end

					
					
		if (	event == "PLAYER_ALIVE" or
				event == "PLAYER_DEAD" or
				event == "PLAYER_UNGHOST" or
				event == "PLAYER_CAMPING" ) then				

			table.insert( SSEventLog.logs, logHeader )
			logChatFrame:AddMessage( "SS: " .. displayHeader  )

			RequestTimePlayed()


		elseif ( event == "PLAYER_LEVEL_UP" ) then
			local newLevel = ...
			
			local logEntry = logHeader .. "|" .. newLevel
			local displayEntry = displayHeader .. " ### |cFF0099FFNew Lvl: |cFFFF7633>|cFFDD33FF" .. newLevel .. "|cFFFF7633<|r"

			table.insert( SSEventLog.logs, logEntry )
			logChatFrame:AddMessage( "SS: " .. displayEntry )

			RequestTimePlayed()


		elseif ( event == "TIME_PLAYED_MSG" ) then
			local totalTime, levelTime = ...

			local logEntry = logHeader .. "|" .. totalTime .. "|" .. levelTime
			local displayEntry = displayHeader .. " ### |cFF0099FFPlayed: |cFFFF7633>|cFFDD33FF" .. totalTime ..
								"|cFFFF7633<|cFF0099FF Lvl Played: |cFFFF7633>|cFFDD33FF" .. levelTime .. "|cFFFF7633<|r"

			table.insert( SSEventLog.logs, logEntry )
			logChatFrame:AddMessage( "SS: " .. displayEntry  )


		elseif ( event == "QUEST_ACCEPTED" ) then
			local questSlot, questId = ...		

			local logEntry = logHeader .. "|" .. questSlot .. "|" .. questId
			local displayEntry = displayHeader .. " ### |cFF0099FFQuest Slot: |cFFFF7633>|cFFDD33FF" .. questSlot ..
					"|cFFFF7633<|cFF0099FF Quest ID: |cFFFF7633>|cFFDD33FF" .. questId .. "|cFFFF7633<|r"

			table.insert( SSEventLog.logs, logEntry )
			logChatFrame:AddMessage( "SS: " .. displayEntry  )
			
			RequestTimePlayed()
		

		elseif ( event == "QUEST_REMOVED" ) then
			local questId = ...		

			local logEntry = logHeader .. "|" .. questId			
			local displayEntry = displayHeader .. " ### |cFF0099FFQuest ID: |cFFFF7633>|cFFDD33FF" .. questId .. "|cFFFF7633<|r"			

			table.insert( SSEventLog.logs, logEntry )
			logChatFrame:AddMessage( "SS: " .. displayEntry  )

			RequestTimePlayed()


		elseif ( event == "QUEST_TURNED_IN" ) then
			local questId, questXP, questCopper = ...		

			local logEntry = logHeader .. "|" .. questId .. "|" .. questXP .. "|" .. questCopper
			local displayEntry = displayHeader .. " ### |cFF0099FFQuest ID: |cFFFF7633>|cFFDD33FF" .. questId ..
					"|cFFFF7633<|cFF0099FF QuestXP: >" .. questXP .. "|cFF0099FF< QuestCopper: |cFFFF7633>|cFFDD33FF" ..
					questCopper .. "|cFFFF7633<|r"

			table.insert( SSEventLog.logs, logEntry )
			logChatFrame:AddMessage( "SS: " .. displayEntry  )

			RequestTimePlayed()


		elseif ( event == "PLAYER_FLAGS_CHANGED" ) then		
			local unit = ...
			
			if ( unit == "player" ) then
				local afkState = UnitIsAFK( "player" ) and "Y" or "N"

				local logEntry = logHeader .. "|" .. afkState
				local displayEntry = displayHeader .. " ### |cFF0099FFAFK: |cFFFF7633>|cFFDD33FF" .. afkState ..
									"|cFFFF7633<|r"	

				table.insert( SSEventLog.logs, logEntry )
				logChatFrame:AddMessage( "SS: " .. displayEntry  )
			end
			-- RequestTimePlayed()


		elseif ( event == "CHECKPOINT_COMMENT" ) then		
			local comment = ...
			
			local logEntry = logHeader .. "|" .. comment
			local displayEntry = displayHeader .. " ### |cFF0099FFComment: |cFFFF7633>|cFFDD33FF" .. comment ..
									"|cFFFF7633<|r"	

			table.insert( SSEventLog.logs, logEntry )
			logChatFrame:AddMessage( "SS: " .. displayEntry  )
			
			RequestTimePlayed()


		elseif ( event == "UNIT_SPELLCAST_START" ) then		
			local unitName, unitSpell = ...
			local textLevel = '' .. unitLevel .. ''

			if ( unitName == "player" ) then
				prepareChild( SSEventLog.counts.spells, textLevel )
				prepareChild( SSEventLog.counts.spells[textLevel], unitSpell )

				SSEventLog.counts.spells[textLevel][unitSpell].start = ( SSEventLog.counts.spells[textLevel][unitSpell].start or 0 ) + 1

				local logEntry = logHeader .. "|" .. unitSpell
				local displayEntry = displayHeader .. " ### |cFF0099FFStart Cast: |cFFFF7633>|cFFDD33FF" .. unitSpell ..
										"|cFFFF7633<|r"	

				logChatFrame:AddMessage( "SS: " .. displayEntry  )
			end


		elseif ( event == "UNIT_SPELLCAST_INTERRUPTED" ) then		
			local unitName, unitSpell = ...
			local textLevel = '' .. unitLevel .. ''
			
			if ( unitName == "player" ) then
				prepareChild( SSEventLog.counts.spells, textLevel )
				prepareChild( SSEventLog.counts.spells[textLevel], unitSpell )

				SSEventLog.counts.spells[textLevel][unitSpell].interrupted = ( SSEventLog.counts.spells[textLevel][unitSpell].interrupted or 0 ) + 1

				local logEntry = logHeader .. "|" .. unitSpell
				local displayEntry = displayHeader .. " ### |cFF0099FFSpell Interrupted: |cFFFF7633>|cFFDD33FF" .. unitSpell ..
										"|cFFFF7633<|r"	

				logChatFrame:AddMessage( "SS: " .. displayEntry  )
			end


		elseif ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then		
			local unitName, unitSpell = ...
			local textLevel = '' .. unitLevel .. ''
			
			if ( unitName == "player" ) then
				prepareChild( SSEventLog.counts.spells, textLevel )
				prepareChild( SSEventLog.counts.spells[textLevel], unitSpell )

				SSEventLog.counts.spells[textLevel][unitSpell].succeeded = ( SSEventLog.counts.spells[textLevel][unitSpell].succeeded or 0 ) + 1

				local logEntry = logHeader .. "|" .. unitSpell
				local displayEntry = displayHeader .. " ### |cFF0099FFSpell Succeeded: |cFFFF7633>|cFFDD33FF" .. unitSpell ..
										"|cFFFF7633<|r"	

				logChatFrame:AddMessage( "SS: " .. displayEntry  )
			end


		elseif ( event == "UNIT_SPELLCAST_FAIL" ) then		
			local unitName, unitSpell = ...
			local textLevel = '' .. unitLevel .. ''
			
			if ( unitName == "player" ) then
				prepareChild( SSEventLog.counts.spells, textLevel )
				prepareChild( SSEventLog.counts.spells[textLevel], unitSpell )

				SSEventLog.counts.spells[textLevel][unitSpell].fail = ( SSEventLog.counts.spells[textLevel][unitSpell].fail or 0 ) + 1

				local logEntry = logHeader .. "|" .. unitSpell
				local displayEntry = displayHeader .. " ### |cFF0099FFSpell Failed: |cFFFF7633>|cFFDD33FF" .. unitSpell ..
										"|cFFFF7633<|r"	

				logChatFrame:AddMessage( "SS: " .. displayEntry  )
			end


		elseif ( event == "UNIT_SPELLCAST_STOP" ) then		
			local unitName, unitSpell = ...
			local textLevel = '' .. unitLevel .. ''
			
			if ( unitName == "player" ) then
				prepareChild( SSEventLog.counts.spells, textLevel )
				prepareChild( SSEventLog.counts.spells[textLevel], unitSpell )

				SSEventLog.counts.spells[textLevel][unitSpell].stop = ( SSEventLog.counts.spells[textLevel][unitSpell].stop or 0 ) + 1

				local logEntry = logHeader .. "|" .. unitSpell
				local displayEntry = displayHeader .. " ### |cFF0099FFSpell Stop: |cFFFF7633>|cFFDD33FF" .. unitSpell ..
										"|cFFFF7633<|r"	

				logChatFrame:AddMessage( "SS: " .. displayEntry  )
			end


		elseif ( event == "UPDATE_CHAT_WINDOWS" ) then		
			updateLoggingChatWindow()	

			table.insert( SSEventLog.logs, logHeader )
			logChatFrame:AddMessage( "SS: " .. displayHeader  )


		elseif ( event == "PLAYER_LOGIN" ) then						
			loggedIn = true

			table.insert( SSEventLog.logs, logHeader )
			logChatFrame:AddMessage( "SS: " .. displayHeader  )


		elseif ( event == "PLAYER_LOGOUT" ) then						
			loggedIn = false
			
			table.insert( SSEventLog.logs, logHeader )
			logChatFrame:AddMessage( "SS: " .. displayHeader  )


		-- Generic log entries go here
		elseif ( 	event == "UNIT_QUEST_LOG_CHANGED" or
					event == "ZONE_CHANGED_NEW_AREA" or
					event == "ZONE_CHANGED" or
					event == "ZONE_CHANGED_INDOORS" or
					event == "HEARTBEAT_LOCATION" ) then		

			table.insert( SSEventLog.logs, logHeader )
			logChatFrame:AddMessage( "SS: " .. displayHeader  )	

		else
			
			table.insert( SSEventLog.logs, logHeader )
			logChatFrame:AddMessage( "SS: " .. displayHeader  )	
		end

	end 
	
end

-- Set the event script for our main event frame
Listening_EventFrame:SetScript( "OnEvent", eventHandler )




function debugHandler( self, event, ... )
	--logChatFrame:AddMessage( "Event: |cFFFF0000" .. event .. "|r Time: |cFF00FF00" .. date( "%c", GetServerTime() ) .. "|r" )

	local serverTime = GetServerTime()
	local prettyTime = date( "%c", serverTime )
	
	local logEntry = event .. "|" .. serverTime
	local displayEntry = "|cFFFF0000" .. event .. "|r - Time: >" .. serverTime ..
				"< P Time: >" .. prettyTime .. "< ###"
	
	local k, v
	for k, v in pairs( {...} ) do
		if ( type( v ) == "boolean" ) then
			prettyV = v and "true" or "false"
		else
			prettyV = v
		end

		logEntry = logEntry .. "|" .. k .. "*" .. prettyV
		displayEntry = displayEntry .. " |cFF0099FFarg|cFFFF7633[|cFFDD33FF" .. k .. "|cFF0099FF]: |cFFFF7633>|cFFDD33FF" .. prettyV .. "|cFFFF7633<|r"
	end

	table.insert( SSEventLog.debugLogs, logEntry )
	logChatFrame:AddMessage( "Debug: " .. displayEntry  )
end

Debugging_EventFrame:SetScript( "OnEvent", debugHandler )


function updateLoggingChatWindow()
	for i = 1, NUM_CHAT_WINDOWS do
		local windowName = GetChatWindowInfo( i )

		logChatFrame:AddMessage( "ChatWindow|cFFFF7633[|cFFDD33FF" .. i .. "|cFFFF7633]|r: \"|cFFDD33FF" .. windowName .. "|r\"" )

	 	if  windowName == "SS Log" then
	 		logChatFrame:AddMessage( "Switching output to \"SS Log\" frame at index " .. i )
			logChatFrame = _G["ChatFrame" .. i]
			logChatFrame:AddMessage( "Chat frame switched" )
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

	logChatFrame:AddMessage( "SSEventLog.debugLogs Type: " .. type( SSEventLog.debugLogs ) )

	if type( SSEventLog.debugLogs ) ~= "table" then
		SSEventLog.debugLogs = {}
		logChatFrame:AddMessage( "SSEventLog.debugLogs created" )
	end

	logChatFrame:AddMessage( "SSEventLog.counts Type: " .. type( SSEventLog.counts ) )

	if type( SSEventLog.counts ) ~= "table" then
		SSEventLog.counts = {}
		logChatFrame:AddMessage( "SSEventLog.counts created" )
	end

	prepareChild( SSEventLog.counts, 'spells' )


	-- Log Version
	local serverTime = GetServerTime()
	local prettyTime = date( "%c", serverTime )
	local factionGroup, factionName = UnitFactionGroup( "player" )
	local charSex = "U"
	local unitSex = UnitSex( "player" )

	if ( unitSex == 2 ) then charSex = "M"
	elseif ( unitSex == 3 ) then charSex = "F"
	end

	local logEntry = "SS_INFO_VERSION|" .. serverTime .. "|" .. version .. "|" .. UnitName( "player" ) .. "|" ..
						GetRealmName() .. "|" .. UnitClass( "player" ) .. "|" .. UnitRace( "player" ) ..
						"|" .. factionGroup .. "|" .. UnitSex( "player" )
	local displayEntry = "|cFFFF0000SS_INFO_VERSION|r - |cFF0099FFTime: |cFFFF7633>|cFFDD33FF" .. serverTime ..
						"|cFFFF7633<|cFF0099FF P Time: |cFFFF7633>|cFFDD33FF" .. prettyTime .. "|cFFFF7633<|cFF0099FF Version: |cFFFF7633>|cFFDD33FF" ..
						version .. "|cFFFF7633<|cFF0099FF Char: |cFFFF7633>|cFFDD33FF" .. UnitName( "player" ) ..
						"|cFFFF7633<|cFF0099FF Realm: |cFFFF7633>|cFFDD33FF" .. GetRealmName() .. "|cFFFF7633<|cFF0099FF Class: |cFFFF7633>|cFFDD33FF" ..
						UnitClass( "player" ) .. "|cFFFF7633<|cFF0099FF Race: |cFFFF7633>|cFFDD33FF" .. UnitRace( "player" ) ..
						"|cFFFF7633<|cFF0099FF Faction: |cFFFF7633>|cFFDD33FF" .. factionGroup .. "|cFFFF7633<|cFF0099FF Sex: |cFFFF7633>|cFFDD33FF" ..
						charSex .. "|cFFFF7633<|r"


	table.insert( SSEventLog.logs, logEntry )
	logChatFrame:AddMessage( "SS: " .. displayEntry  )

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
	Listening_EventFrame:RegisterEvent( "ZONE_CHANGED_INDOORS" )

	-- Spellcasting
	Listening_EventFrame:RegisterEvent( "UNIT_SPELLCAST_START" )
	Listening_EventFrame:RegisterEvent( "UNIT_SPELLCAST_INTERRUPTED" )
	Listening_EventFrame:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED" )
	Listening_EventFrame:RegisterEvent( "UNIT_SPELLCAST_FAILED" )
	Listening_EventFrame:RegisterEvent( "UNIT_SPELLCAST_STOP" )


	-- UPDATE_SHAPESHIFT_FORM

	-- Debugging event logs
	-- Debugging_EventFrame:RegisterEvent( "TIME_PLAYED_MSG" )

	Debugging_EventFrame:RegisterEvent( "GROUP_ROSTER_UPDATE" )
	Debugging_EventFrame:RegisterEvent( "PARTY_INVITE_REQUEST" )
	Debugging_EventFrame:RegisterEvent( "PARTY_INVITE_CANCEL" )
	Debugging_EventFrame:RegisterEvent( "PARTY_LEADER_CHANGED" )
	Debugging_EventFrame:RegisterEvent( "PARTY_LOOT_METHOD_CHANGED" )
	Debugging_EventFrame:RegisterEvent( "PARTY_MEMBERS_CHANGED" )
	Debugging_EventFrame:RegisterEvent( "PARTY_MEMBER_DISABLE" )
	Debugging_EventFrame:RegisterEvent( "PARTY_MEMBER_ENABLE" )
	Debugging_EventFrame:RegisterEvent( "PARTY_REFER_A_FRIEND_UPDATED" )
	Debugging_EventFrame:RegisterEvent( "UNIT_PHASE" )


	-- RaF related events



end


-- OnUpdate function to perform heartbeat actions
function heartbeatHandler( self, elapsed )
	playedHeartbeatElapsed = playedHeartbeatElapsed + elapsed
	locationHeartbeatElapsed = locationHeartbeatElapsed + elapsed

	if ( playedHeartbeatElapsed > playedHeartbeatInterval ) then
		RequestTimePlayed()

		-- reset played and location because played event will log location as well
		playedHeartbeatElapsed = 0
		locationHeartbeatElapsed = 0
	elseif ( locationHeartbeatElapsed > locationHeartbeatInterval ) then
		eventHandler( self, "HEARTBEAT_LOCATION")

		-- Only reset location so that we will still trigger played later
		locationHeartbeatElapsed = 0
	end



end


Listening_EventFrame:SetScript( "OnUpdate", heartbeatHandler )



-- Register slash command
SLASH_SOUCASTATS1 = '/sscp'

function slashHandler( arg, editbox )
	eventHandler( self, "CHECKPOINT_COMMENT", arg )
end

SlashCmdList["SOUCASTATS"] = slashHandler



function prepareChild( parent, child )
	if type( parent[child] ) ~= "table" then
		parent[child] = {}
	end
end

-- UI_INFO_MESSAGE
-- Arg1: 287 ??
-- Arg2: "Lynx Collar: 8/8"

-- UI_INFO_MESSAGE
-- Arg1: 284 ??
-- Arg2: "Objective Complete"



-- /run for i = 1, NUM_CHAT_WINDOWS do print( "[" .. i .. "][" .. GetChatWindowInfo( i ) .. "]" ) end
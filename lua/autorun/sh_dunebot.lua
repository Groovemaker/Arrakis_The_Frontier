AddCSLuaFile()
DuneBot = {}
DuneBot.msgs = {}
DuneBot.isSpawned = 0
DuneBot.Interval = 19

if SERVER then
meta = FindMetaTable( "Player" )



concommand.Add("dune_bot_spawn",function()

	DuneBot.isSpawned = 1
	BroadcastLua([[DuneBot.isSpawned = 1]])
	local Names = {
		"Stormloller6969",
		"Xx_Slayer69_xX",
		"Wike",
		"Prolapser83",
		"Rübengeist"
	}
	local NewBot = player.CreateNextBot(Names[math.random(#Names)])
	NewBot.IsDuneBot = true
	NewBot:TBotResetAI()
	NewBot:SetModel("models/player/leet.mdl")
		
end)

concommand.Add("dune_bot_deletus",function()
	for k, v in pairs( player.GetAll() ) do
		if v:IsBot() then
			v:Kick("BEGONE")
		end
	end
	BroadcastLua([[DuneBot.isSpawned = 0]])
	DuneBot.isSpawned = 0
end)

local BOT						=	FindMetaTable( "Player" )
function BOT:TBotResetAI()
	
	self.Enemy				=	nil -- Refresh our enemy.
	
	self.Goal				=	nil -- The vector goal we want to get to.
	self.NavmeshNodes		=	{} -- The nodes given to us by the pathfinder
	self.Path				=	nil -- The nodes converted into waypoints by our visiblilty checking.
	
	self:TBotCreateThinking() -- Start our AI
	
end

--------------------
--------------------
-------------------- Bot AI is courtesy of Zenlenafelex [PSF]
--------------------
--------------------
hook.Add( "StartCommand" , "DuneBotAIHook" , function( bot , cmd )
	if !IsValid( bot ) or !bot:IsBot() or !bot:Alive() or !bot.IsDuneBot then return end
	-- Make sure we can control this bot and its not a player.
	
	cmd:ClearButtons() -- Clear the bots buttons. Shooting, Running , jumping etc...
	cmd:ClearMovement() -- For when the bot is moving around.
	
	-- Only using bot:HasWeapon() just for this example!
	if bot:HasWeapon( "weapon_crowbar" ) then
		
		-- Get the weapon entity by its class name, Then select it.
		cmd:SelectWeapon( bot:GetWeapon( "weapon_crowbar" ) )
		
	end
	
	
	
	-- Better make sure they exist of course.
	if IsValid( bot.Enemy ) then
		
		-- Attack and run
		cmd:SetButtons( bit.bor( IN_ATTACK , IN_SPEED ) )
		
		-- Instantly face our enemy!
		-- CHALLANGE: Can you make them turn smoothly?
		if bot.Enemy:IsPlayer() then
			bot:SetEyeAngles( ( bot.Enemy:GetShootPos() - bot:GetShootPos() ):GetNormalized():Angle() )
		else
			bot:SetEyeAngles( ( bot.Enemy:GetPos() - bot:GetShootPos() ):GetNormalized():Angle() )
		end
		if isvector( bot.Goal ) then
			
			bot:TBotUpdateMovement( cmd ) -- Move when we need to.
			
		else
			
			bot:TBotSetNewGoal( bot.Enemy:GetPos() )
			
		end
		
	end
	
	
	
end)







-- Just a simple way to respawn a bot.
hook.Add( "PlayerDeath" , "DuneBotRespawn" , function( ply )
	if ply:IsBot() and ply.IsDuneBot then 
		timer.Simple( 3 , function()
			if IsValid( ply ) then
				ply:Spawn()
			end
		end)
	end
end)

-- Reset their AI on spawn.
hook.Add( "PlayerSpawn" , "DuneBotSpawnHook" , function( ply )
	if ply:IsBot() and ply.IsDuneBot then
		ply:SetModel("models/player/leet.mdl")
		ply:TBotResetAI()
	end
end)




function DuneBotPathfinder( StartNode , GoalNode )
	if !IsValid( StartNode ) or !IsValid( GoalNode ) then return false end
	if ( StartNode == GoalNode ) then return true end
	
	StartNode:ClearSearchLists() -- Clear the search lists ready for a new search.
	
	StartNode:SetCostSoFar( 0 ) -- Sets the cost so far. which is beleive is the GCost.
	
	StartNode:SetTotalCost( DuneBotRangeCheck( StartNode , GoalNode ) ) -- Sets the total cost so far. which im quite sure is the FCost.
	
	StartNode:AddToOpenList()
	
	StartNode:UpdateOnOpenList()
	
	local FinalPath		=	{}
	
	local Attempts		=	0 
	-- Backup Varaible! In case something goes wrong, The game will not get into an infinite loop.
	
	while( !StartNode:IsOpenListEmpty() and Attempts < 6500 ) do
		Attempts		=	Attempts + 1
		
		local Current 	=	StartNode:PopOpenList() -- Get the lowest FCost
		
		if ( Current == GoalNode ) then
			-- We found a path! Now lets retrace it.
			
			
			return DuneBotRetracePath( Current , FinalPath ) -- Retrace the path and return the table of nodes.
		end
		
		Current:AddToClosedList() -- We don't need to deal with this anymore.
		
		for k, neighbor in ipairs( Current:GetAdjacentAreas() ) do
			local Height			=	Current:ComputeAdjacentConnectionHeightChange( neighbor ) 
			
			if Height > 64 then
				-- We can't jump that high.
				
				continue
			end
			
			-- G + H = F
			local NewCostSoFar		=	Current:GetCostSoFar() + DuneBotRangeCheck( Current , neighbor )
			
			if neighbor:IsOpen() or neighbor:IsClosed() and neighbor:GetCostSoFar() <= NewCostSoFar then
				
				continue
				
			else
				neighbor:SetCostSoFar( NewCostSoFar )
				neighbor:SetTotalCost( NewCostSoFar + DuneBotRangeCheck( neighbor , GoalNode ) )
				
				if neighbor:IsClosed() then
					
					neighbor:RemoveFromClosedList()
					
				end
				
				if neighbor:IsOpen() then
					
					neighbor:UpdateOnOpenList()
					
				else
					
					neighbor:AddToOpenList()
					
				end
				
				-- Parenting of the nodes so we can trace the parents back later.
				FinalPath[ neighbor:GetID() ]		=	Current:GetID()
			end
			
		end
		
	end
	
	return false
end



function DuneBotRangeCheck( FirstNode , SecondNode )
	-- Some helper errors.
	if !IsValid( FirstNode ) then error( "Bad argument #1 CNavArea expected got " .. type( FirstNode ) ) end
	if !IsValid( FirstNode ) then error( "Bad argument #2 CNavArea expected got " .. type( SecondNode ) ) end
	
	return FirstNode:GetCenter():Distance( SecondNode:GetCenter() )
end


function DuneBotRetracePath( Current , FinalPath )
	
	local NodePath		=	{ Current }
	
	Current				=	Current:GetID()
	
	while ( FinalPath[ Current ] ) do
		
		Current			=	FinalPath[ Current ]
		table.insert( NodePath , navmesh.GetNavAreaByID( Current ) )
		
	end
	
	
	return NodePath
end


-- The main AI is here.
function BOT:TBotCreateThinking()
	
	local index		=	self:EntIndex()
	
	-- I used math.Rand as a personal preference, It just prevents all the timers being ran at the same time
	-- as other bots timers.
	timer.Create( "tutorial_bot_think" .. index , math.Rand( 0.08 , 0.15 ) , 0 , function()
		
		if IsValid( self ) and self:Alive() then
			
			-- A quick condition statement to check if our enemy is no longer a threat.
			-- Most likely done best in its own function. But for this tutorial we will make it simple.
			if !IsValid( self.Enemy ) then
				
				self.Enemy		=	nil
				
			end
			--print(self.Enemy)
			self:TBotFindRandomEnemy()
			
		else
			
			timer.Remove( "tutorial_bot_think" .. index ) -- We don't need to think while dead.
			
		end
		
	end)
	
end



-- Target any player or bot that is visible to us.
function BOT:TBotFindRandomEnemy()
	if IsValid( self.Enemy ) then return end
	
	local VisibleEnemies	=	{} -- So we can select a random enemy.
	
	for k, v in ipairs( ents.GetAll() ) do
		
		if v != self then -- Make sure they are alive and we don't want to target ourself.
			if v:GetName() == "dune_spiceharvester" || v:IsPlayer() && v:Team() != self:Team() && v:Health() > 0 then
				if v:Visible( self ) then -- Using Visible() as an example of why we should delay the thinking.
					
					VisibleEnemies[ #VisibleEnemies + 1 ]		=	v
					
				end
			end
		end
		
	end
	
	self.Enemy		=	VisibleEnemies[ math.random( 1 , #VisibleEnemies ) ]
	
end

function BOT:TBotSetNewGoal( NewGoal )
	if !isvector( NewGoal ) then error( "Bad argument #1 vector expected got " .. type( NewGoal ) ) end
	
	self.Goal				=	NewGoal
	
	self:TBotCreateNavTimer()
	
end






-- A handy function for range checking.
local function IsVecCloseEnough( start , endpos , dist )
	
	return start:DistToSqr( endpos ) < dist * dist
	
end

local function CheckLOS( val , pos1 , pos2 )
	
	local Trace				=	util.TraceLine({
		
		start				=	pos1 + Vector( val , 0 , 0 ),
		endpos				=	pos2 + Vector( val , 0 , 0 ),
		collisiongroup 		=	COLLISION_GROUP_DEBRIS,
		
	})
	
	if Trace.Hit then return false end
	
	Trace					=	util.TraceLine({
		
		start				=	pos1 + Vector( -val , 0 , 0 ),
		endpos				=	pos2 + Vector( -val , 0 , 0 ),
		collisiongroup 		=	COLLISION_GROUP_DEBRIS,
		
	})
	
	if Trace.Hit then return false end
	
	
	Trace					=	util.TraceLine({
		
		start				=	pos1 + Vector( 0 , val , 0 ),
		endpos				=	pos2 + Vector( 0 , val , 0 ),
		collisiongroup 		=	COLLISION_GROUP_DEBRIS,
		
	})
	
	if Trace.Hit then return false end
	
	Trace					=	util.TraceLine({
		
		start				=	pos1 + Vector( 0 , -val , 0 ),
		endpos				=	pos2 + Vector( 0 , -val , 0 ),
		collisiongroup 		=	COLLISION_GROUP_DEBRIS,
		
	})
	
	if Trace.Hit then return false end
	
	return true
end

local function SendBoxedLine( pos1 , pos2 )
	
	for i = 1, 12 do
		
		if CheckLOS( 3 * i , pos1 , pos2 ) == false then return false end
		
	end
	
	return true
end


-- Creates waypoints using the nodes.
function BOT:ComputeNavmeshVisibility()
	
	self.Path				=	{}
	
	local LastVisPos		=	self:GetPos()
	
	for k, CurrentNode in ipairs( self.NavmeshNodes ) do
		-- You should also make sure that the nodes exist as this is called 0.03 seconds after the pathfind.
		-- For tutorial sakes ill keep this simple.
		
		local NextNode		=	self.NavmeshNodes[ k + 1 ]
		
		if !IsValid( NextNode ) then
			
			self.Path[ #self.Path + 1 ]		=	self.Goal
			
			break
		end
		
		
		
		-- The next area ahead's closest point to us.
		local NextAreasClosetPointToLastVisPos		=	NextNode:GetClosestPointOnArea( LastVisPos ) + Vector( 0 , 0 , 32 )
		local OurClosestPointToNextAreasClosestPointToLastVisPos	=	CurrentNode:GetClosestPointOnArea( NextAreasClosetPointToLastVisPos ) + Vector( 0 , 0 , 32 )
		
		-- If we are visible then we shall put the waypoint there.
		if SendBoxedLine( LastVisPos , OurClosestPointToNextAreasClosestPointToLastVisPos ) == true then
			
			LastVisPos						=	OurClosestPointToNextAreasClosestPointToLastVisPos
			self.Path[ #self.Path + 1 ]		=	OurClosestPointToNextAreasClosestPointToLastVisPos
			
			continue
		end
		
		
		
		
		self.Path[ #self.Path + 1 ]			=	CurrentNode:GetCenter()
		
	end
	
end


-- The main navigation code ( Waypoint handler )
function BOT:TBotNavigation()
	if !isvector( self.Goal ) then return end -- A double backup!
	
	-- The CNavArea we are standing on.
	self.StandingOnNode			=	navmesh.GetNearestNavArea( self:GetPos() )
	if !IsValid( self.StandingOnNode ) then return end -- The map has no navmesh.
	
	
	if !istable( self.Path ) or !istable( self.NavmeshNodes ) or table.IsEmpty( self.Path ) or table.IsEmpty( self.NavmeshNodes ) then
		
		
		if self.BlockPathFind != true then
			
			
			-- Get the nav area that is closest to our goal.
			local TargetArea		=	navmesh.GetNearestNavArea( self.Goal )
			
			self.Path				=	{} -- Reset that.
			
			-- Find a path through the navmesh to our TargetArea
			self.NavmeshNodes		=	DuneBotPathfinder( self.StandingOnNode , TargetArea )
			
			
			-- Prevent spamming the pathfinder.
			self.BlockPathFind		=	true
			timer.Simple( 0.25 , function()
				
				if IsValid( self ) then
					
					self.BlockPathFind		=	false
					
				end
				
			end)
			
			
			-- Give the computer some time before it does more expensive checks.
			timer.Simple( 0.03 , function()
				
				-- If we can get there and is not already there, Then we will compute the visiblilty.
				if IsValid( self ) and istable( self.NavmeshNodes ) then
					
					self.NavmeshNodes	=	table.Reverse( self.NavmeshNodes )
					
					self:ComputeNavmeshVisibility()
					
				end
				
			end)
			
			
			-- There is no way we can get there! Remove our goal.
			if self.NavmeshNodes == false then
				
				self.Goal		=	nil
				
				return
			end
			
			
		end
		
		
	end
	
	
	if istable( self.Path ) then
		
		if self.Path[ 1 ] then
			
			local Waypoint2D		=	Vector( self.Path[ 1 ].x , self.Path[ 1 ].y , self:GetPos().z )
			-- ALWAYS: Use 2D navigation, It helps by a large amount.
			
			if self.Path[ 2 ] and IsVecCloseEnough( self:GetPos() , Waypoint2D , 600 ) and SendBoxedLine( self.Path[ 2 ] , self:GetPos() + Vector( 0 , 0 , 15 ) ) == true and self.Path[ 2 ].z - 20 <= Waypoint2D.z then
				
				table.remove( self.Path , 1 )
				
			elseif IsVecCloseEnough( self:GetPos() , Waypoint2D , 24 ) then
				
				table.remove( self.Path , 1 )
				
			end
			
		end
		
	end
	
	
end

-- The navigation and navigation debugger for when a bot is stuck.
function BOT:TBotCreateNavTimer()
	
	local index				=	self:EntIndex()
	local LastBotPos		=	self:GetPos()
	
	
	timer.Create( "DuneBot_nav" .. index , 0.09 , 0 , function()
		
		if IsValid( self ) and self:Alive() and isvector( self.Goal ) then
			
			self:TBotNavigation()
			
			self:TBotDebugWaypoints()
			
			LastBotPos		=	Vector( LastBotPos.x , LastBotPos.y , self:GetPos().z )
			
			if IsVecCloseEnough( self:GetPos() , LastBotPos , 2 ) then
				
				self.Path	=	nil
				-- TODO/Challange: Make the bot jump a few times, If that does not work. Then recreate the path.
				
			end
			LastBotPos		=	self:GetPos()
			
		else
			
			timer.Remove( "DuneBot_nav" .. index )
			
		end
		
	end)
	
end



-- A handy debugger for the waypoints.
-- Requires developer set to 1 in console
function BOT:TBotDebugWaypoints()
	if !istable( self.Path ) then return end
	if table.IsEmpty( self.Path ) then return end
	
	debugoverlay.Line( self.Path[ 1 ] , self:GetPos() + Vector( 0 , 0 , 44 ) , 0.08 , Color( 0 , 255 , 255 ) )
	debugoverlay.Sphere( self.Path[ 1 ] , 8 , 0.08 , Color( 0 , 255 , 255 ) , true )
	
	for k, v in ipairs( self.Path ) do
		
		if self.Path[ k + 1 ] then
			
			debugoverlay.Line( v , self.Path[ k + 1 ] , 0.08 , Color( 255 , 255 , 0 ) )
			
		end
		
		debugoverlay.Sphere( v , 8 , 0.08 , Color( 255 , 200 , 0 ) , true )
		
	end
	
end


-- Make the bot move.
function BOT:TBotUpdateMovement( cmd )
	if !isvector( self.Goal ) then return end
	
	if !istable( self.Path ) or table.IsEmpty( self.Path ) or isbool( self.NavmeshNodes ) then
		
		local MovementAngle		=	( self.Goal - self:GetPos() ):GetNormalized():Angle()
		
		cmd:SetViewAngles( MovementAngle )
		cmd:SetForwardMove( 1000 )
		
		local GoalIn2D			=	Vector( self.Goal.x , self.Goal.y , self:GetPos().z )
		-- Optionaly you could convert this to 2D navigation as well if you like.
		-- I prefer not to.
		if IsVecCloseEnough( self:GetPos() , GoalIn2D , 32 ) then
			
			self.Goal			=		nil -- We have reached our goal!
			
		end
		
		return
	end
	
	if self.Path[ 1 ] then
		
		local MovementAngle		=	( self.Path[ 1 ] - self:GetPos() ):GetNormalized():Angle()
		
		cmd:SetViewAngles( MovementAngle )
		cmd:SetForwardMove( 1000 )
		
	end
	
end
end


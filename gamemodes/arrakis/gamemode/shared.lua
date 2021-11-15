AddCSLuaFile()

-- Shared
GM.Name = "Arrakis: The Frontier"
GM.Author = "Runic"
GM.Email = "NOP"
GM.Website = "NOP"


function recursiveInclusion( scanDirectory, isGamemode )
	-- Null-coalescing for optional argument
	isGamemode = isGamemode or false
	
	local queue = { scanDirectory }
	
	-- Loop until queue is cleared
	while #queue > 0 do
		-- For each directory in the queue...
		for _, directory in pairs( queue ) do
			-- print( "Scanning directory: ", directory )
			
			local files, directories = file.Find( directory .. "/*", "LUA" )
			
			-- Include files within this directory
			for _, fileName in pairs( files ) do
				if fileName != "shared.lua" and fileName != "init.lua" and fileName != "cl_init.lua" then
					-- print( "Found: ", fileName )
					
					-- Create a relative path for inclusion functions
					-- Also handle pathing case for including gamemode folders
					local relativePath = directory .. "/" .. fileName
					if isGamemode then
						relativePath = string.gsub( directory .. "/" .. fileName, GM.FolderName .. "/gamemode/", "" )
					end
					
					-- Include server files
					if string.match( fileName, "^sv" ) then
						if SERVER then
							include( relativePath )
						end
					end
					
					-- Include shared files
					if string.match( fileName, "^sh" ) then
						AddCSLuaFile( relativePath )
						include( relativePath )
					end
					
					-- Include client files
					if string.match( fileName, "^cl" ) then
						AddCSLuaFile( relativePath )
						
						if CLIENT then
							include( relativePath )
						end
					end
				end
			end
			
			-- Append directories within this directory to the queue
			for _, subdirectory in pairs( directories ) do
				-- print( "Found directory: ", subdirectory )
				table.insert( queue, directory .. "/" .. subdirectory )
			end
			
			-- Remove this directory from the queue
			table.RemoveByValue( queue, directory )
		end
	end
end

recursiveInclusion( GM.FolderName .. "/gamemode", true )


-- Factions
Atreides = 1
Harkonnen = 2
team.SetUp( Atreides, "House Atreides", Color( 11, 255, 155, 255 ) ) 
team.SetUp( Harkonnen, "House Harkonnen", Color( 200, 11, 11, 255 ) )

-- tfa
if SERVER then
	AddCSLuaFile()
end

-- Replicated CVARs
CVAR_DAYNIGHT = CreateConVar( "dune_sv_day", "1", FCVAR_REPLICATED, "Day/Night switch", 0,1)


ScoreAtreides = 0
ScoreHarkonnen = 0
Scores = {
	ScoreAtreides,
	ScoreHarkonnen
}
include("tfa/framework/tfa_loader.lua")
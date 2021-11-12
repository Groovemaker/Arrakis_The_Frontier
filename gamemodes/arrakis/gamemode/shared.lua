AddCSLuaFile()

-- Shared
GM.Name = "Arrakis: The Frontier"
GM.Author = "Runic"
GM.Email = "NOP"
GM.Website = "NOP"

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

include("tfa/framework/tfa_loader.lua")
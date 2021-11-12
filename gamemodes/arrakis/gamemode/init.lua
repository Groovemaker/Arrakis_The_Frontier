-- Serverside
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("shared.lua")

-- Set Skyname
RunConsoleCommand("sv_skyname", "sky_day01_06")

-- Loadout
function GM:PlayerLoadout(ply)
	return true
end

-- Factions
function jAtreides( ply ) 
	ply:StripAmmo()
	ply:StripWeapons()
    ply:SetTeam(1)
    ply:Spawn()
end 
 
function jHarkonnen( ply )
	ply:StripAmmo()
	ply:StripWeapons()
    ply:SetTeam(2)
    ply:Spawn()
end 

concommand.Add( "dune_join_atreides", jAtreides ) //Add the command to set the players team to team 3
concommand.Add( "dune_join_harkonnen", jHarkonnen ) //Add the command to set the players team to team 4

function GM:PlayerSetModel(ply)

	Atreides_PlyMDL = "models/player/barney.mdl"
	Harkonnen_PlyMDL = "models/player/gman_high.mdl"

	if ply:Team() == Atreides then
		ply:Give("tfeye_damo") --melee sword
	    ply:Give("tfeye_s6000") --pulse ar
	    ply:Give("tfeye_rotten") --pulse carbine
	    ply:Give("tfeye_depez") -- shotgun
	    ply:Give("tfeye_ovum") -- grenade launcher
	    --ply:GiveAmmo(32, "357")
	    ply:SetModel(Atreides_PlyMDL)

	elseif ply:Team() == Harkonnen then
	    ply:Give("tfeye_arra") --melee hammer
	    ply:Give("tfeye_ka93") --pulse smg
	    ply:Give("tfeye_huntr") -- carbine
	    ply:Give("tfeye_cawham") --shotgun
	    ply:Give("tfeye_excidium") --grenade launcher
	    --ply:GiveAmmo(32, "357")
	    ply:SetModel(Harkonnen_PlyMDL)
	end
end
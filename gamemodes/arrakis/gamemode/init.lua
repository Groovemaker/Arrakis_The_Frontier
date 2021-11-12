-- Serverside
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- Set Skyname
RunConsoleCommand("sv_skyname", "sky_day01_06")

-- Set up CVARs
CVAR_ShieldInterval = CreateConVar( "dune_sv_recharge_interval", "0.1", FCVAR_NONE, "The lower, the faster the shield recharges", 0.01)
CVAR_ShieldDelay = CreateConVar( "dune_sv_recharge_delay", "1", FCVAR_NONE, "The lower, the sooner the shield starts recharging", 0.1)

-- Loadout
function GM:PlayerLoadout(ply)
	ply:SetArmor(100)
	return true
end

-- Factions
function jAtreides( ply ) 
	ply:StripAmmo()
	ply:StripWeapons()
    ply:SetTeam(1)
    ply:Spawn()
    ChatAdd("TEAMCHANGE"," joined House Atreides!",{1,ply:Nick()})
end 
 
function jHarkonnen( ply )
	ply:StripAmmo()
	ply:StripWeapons()
    ply:SetTeam(2)
    ply:Spawn()
    ChatAdd("TEAMCHANGE"," joined House Harkonnen!",{2,ply:Nick()})
end 

concommand.Add( "dune_join_atreides", jAtreides ) //Add the command to set the players team to team 3
concommand.Add( "dune_join_harkonnen", jHarkonnen ) //Add the command to set the players team to team 4
function ChatAdd(type,message,args)
	if type == "JL" then
		BroadcastLua([[chat.AddText(Color(255,155,50),"[SERVER]: ",Color(255,200,100),"]]..args..[[",Color(255,255,255),"]]..message..[[")]])
	elseif type == "TEAMCHANGE" then
		if args[1] == 1 then
			BroadcastLua([[chat.AddText(Color(255,155,50),"[SERVER]: ",Color(255,200,100),"]]..args[2]..[[",Color(111,200,155),"]]..message..[[")]])
		elseif args[1] == 2 then
			BroadcastLua([[chat.AddText(Color(255,155,50),"[SERVER]: ",Color(255,200,100),"]]..args[2]..[[",Color(155,55,11),"]]..message..[[")]])
		end
	end
end
hook.Add("PlayerSpawn","Dune_Spawn",function(ply)
	SP_Atreides = {

	}
	SP_Harkonnen = {
		Vector(-12395.594727, 11587.176758, -9147.045898),
		Vector(-12814.399414, 10839.073242, -9256.389648),
		Vector(-12302.385742, 10749.623047, -9257.607422),
		Vector(-12859.300781, 10293.492188, -9312.452148),
		Vector(-13258.383789, 10780.868164, -9239.381836),
		Vector(-13702.872070, 10912.717773, -9183.007813)
	}
	if ply:Team() == 1 then

	elseif ply:Team() == 2 then
		ply:SetPos(table.Random(SP_Harkonnen))
		ply:SetAngles(Angle(15.012362, -49.033779, 0))
	end
end)

hook.Add("PlayerInitialSpawn","Dune_JL",function(ply)
	ChatAdd("JL"," joined the Battlefield!",ply:Nick())
	ply:ConCommand("dune_team")
end)
function GM:PlayerShouldTakeDamage(ply,attacker)
	return ply == attacker || ply:Team() != attacker:Team()
end
function GM:PlayerSetModel(ply)

	Atreides_PlyMDL = "models/player/swat.mdl"
	Harkonnen_PlyMDL = "models/player/combine_soldier.mdl"

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
	  	ply:Give("tfeye_depez") --shotgun
	    ply:Give("tfeye_excidium") --grenade launcher
	    --ply:GiveAmmo(32, "357")
	    ply:SetModel(Harkonnen_PlyMDL)
	end
end
function GM:PlayerHurt(victim, attacker)
	timer.Stop("Recharge_"..victim:SteamID())
	timer.Stop("Recharge_Starter_"..victim:SteamID())
	timer.Create( "Recharge_Starter_"..victim:SteamID(), CVAR_ShieldDelay:GetFloat(), 1, function() 
		if victim:Armor() == 0 then
			timer.Create( "Recharge_"..victim:SteamID(), CVAR_ShieldInterval:GetFloat(), 100, function() 
				victim:SetArmor(victim:Armor()+1)
			end)
		else
			timer.Create( "Recharge_"..victim:SteamID(), CVAR_ShieldInterval:GetFloat(), 100-victim:Armor(), function() 
				victim:SetArmor(victim:Armor()+1)
			end)
		end
	end)
end
--
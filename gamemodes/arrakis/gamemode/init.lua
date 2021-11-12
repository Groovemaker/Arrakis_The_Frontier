-- Serverside
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

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

hook.Add("PlayerInitialSpawn","Dune_JL",function(ply)
	ChatAdd("JL"," joined the Battlefield!",ply:Nick())
	ply:ConCommand("dune_team")
end)

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
	    ply:Give("tfeye_cawham") --shotgun
	    ply:Give("tfeye_excidium") --grenade launcher
	    --ply:GiveAmmo(32, "357")
	    ply:SetModel(Harkonnen_PlyMDL)
	end
end
function GM:PlayerHurt(victim, attacker)
	timer.Stop("Recharge_"..victim:SteamID())
	timer.Stop("Recharge_Starter_"..victim:SteamID())
	timer.Create( "Recharge_Starter_"..victim:SteamID(), 1, 1, function() 
		if victim:Armor() == 0 then
			timer.Create( "Recharge_"..victim:SteamID(), GetConVar("dune_sv_recharge_interval"):GetFloat(), 100, function() 
				victim:SetArmor(victim:Armor()+1)
			end)
		else
			timer.Create( "Recharge_"..victim:SteamID(), GetConVar("dune_sv_recharge_interval"):GetFloat(), 100-victim:Armor(), function() 
				victim:SetArmor(victim:Armor()+1)
			end)
		end
	end)
end
--
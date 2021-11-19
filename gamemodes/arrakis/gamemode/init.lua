-- Serverside
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
-- When Hotfixing, tell people
BroadcastLua([[chat.AddText(Color(255,155,50),"[Arrakis: The Frontier]: ",Color(111,155,255),"init.lua ",Color(255,255,255),"reloaded!")]])
TFA_BASE_VERSION = 1337

-- Netstrings
util.AddNetworkString("ScoreManip")
util.AddNetworkString("Capture")
util.AddNetworkString("Decapture")
util.AddNetworkString("HarvesterManip")
util.AddNetworkString("PlyKill")

-- Resources
resource.AddFile("materials/atreides.png")
resource.AddFile("materials/harkonnen.png")
resource.AddFile("materials/ability_grenade.png")
resource.AddFile("sound/arrakis_credits.mp3")
resource.AddFile("sound/arrakis_ambience.wav")
resource.AddFile("sound/grenade_recharged.wav")
resource.AddFile("resource/fonts/RobotoMono.ttf")
resource.AddFile("resource/fonts/Orbitron.ttf")
resource.AddFile("resource/fonts/Cairo.ttf")

resource.AddWorkshop( "1622006977" ) -- Harkonnen VTOL
resource.AddWorkshop( "831680603" ) --  Simfphys APC
resource.AddWorkshop( "2334354896" ) -- Atreides/Fremen VTOLs
resource.AddWorkshop( "2211859288" ) -- Crysis Weapons
resource.AddWorkshop( "415143062" ) --  TFA Redux
resource.AddWorkshop( "848490709" ) -- TFA KF2 Melee
resource.AddWorkshop( "223357888" ) -- Playermodel Harkonnen

MapStore = {}

function ReadMapStore()
	-- Make sure you use the same filename as the one in file.Write!
	local JSONData = file.Read("arrakis/maps/"..game.GetMap()..".rakmap")
	MapStore = util.JSONToTable(JSONData)
	print("Loading rakmap Mapstore Data...")
	PrintTable(MapStore)

end

ReadMapStore()

-- Mapdata
SPP = MapStore["SPP"]
SP_Vtols_Harkonnen = MapStore["Harkonnen"]["Vtols"]
SP_APC_Harkonnen = MapStore["Harkonnen"]["APCs"]
SP_Vtols_Atreides = MapStore["Atreides"]["Vtols"]
SP_APC_Atreides = MapStore["Atreides"]["APCs"]
SP_Harkonnen = MapStore["Harkonnen"]["PlySpawns"]
SP_Atreides = MapStore["Atreides"]["PlySpawns"]
SpicePos = MapStore["SpicefogPos"]

SPH = {}
-- Round Vars
RoundHasEnded = 0

-- Set Skyname
RunConsoleCommand("sv_skyname", "sky_day01_06")
RunConsoleCommand("sv_tfa_cmenu_key","27")
RunConsoleCommand("sv_tfa_attachments_enabled","1")

-- Set up CVARs
CVAR_CaptureTime = CreateConVar( "dune_sv_capture_time", "5", FCVAR_NONE+FCVAR_NOTIFY, "Time needed to capture harvesters", 0.01)
CVAR_GrenadeCooldown = CreateConVar( "dune_sv_grenade_cooldown", "7", FCVAR_NONE+FCVAR_NOTIFY, "The lower, the faster the Grenade recharges", 0.01)
CVAR_ShieldInterval = CreateConVar( "dune_sv_recharge_interval", "0.1", FCVAR_NONE+FCVAR_NOTIFY, "The lower, the faster the shield recharges", 0.01)
CVAR_ShieldDelay = CreateConVar( "dune_sv_recharge_delay", "1", FCVAR_NONE+FCVAR_NOTIFY, "The lower, the sooner the shield starts recharging", 0.1)
CVAR_Gamemode = CreateConVar( "dune_sv_gamemode", "2", FCVAR_NONE+FCVAR_NOTIFY, "1 - DM; 2 - Spice Harvest", 1,2)
--CVAR_Aleph = CreateConVar( "dune_sv_alephmode", "0", FCVAR_NONE+FCVAR_NOTIFY+FCVAR_UNREGISTERED, "Easteregg lol", 0,1)

-- Loadout
function GM:PlayerLoadout(ply)
	ply:SetArmor(100)
	ply:ShouldDropWeapon(1)
	timer.Simple(0.3, function() 
	    for k,v in pairs(ply:GetWeapons()) do
	    	if v:GetClass() == "tfa_bcry2_gauss" then
	    		ply:GiveAmmo(25,v:GetPrimaryAmmoType(),true)
	    	else
	    		ply:GiveAmmo(150,v:GetPrimaryAmmoType(),true)
	    	end
	    end
	end)
	return true
end

-- Thx to Omni Games on YT!
function AutoBalance()
	/*
	if table.Count(team.GetPlayers(1)) > table.Count(team.GetPlayers(2)) then
		return 2
	elseif table.Count(team.GetPlayers(1)) < table.Count(team.GetPlayers(2)) then
		return 1
	else*/
		local KDR_Atreides = 0
		local KDR_Harkonnen = 0
		for k,v in pairs(team.GetPlayers(1)) do
			KDR_Atreides = KDR_Atreides + v:Frags()/v:Deaths()
		end
		KDR_Atreides = KDR_Atreides/table.Count(team.GetPlayers(1))

		for k,v in pairs(team.GetPlayers(2)) do
			KDR_Harkonnen = KDR_Harkonnen + v:Frags()/v:Deaths()
		end
		KDR_Harkonnen = KDR_Harkonnen/table.Count(team.GetPlayers(2))

		if KDR_Atreides > KDR_Harkonnen then
			return 2
		elseif KDR_Atreides < KDR_Harkonnen then
			return 1
		else
			return math.random(0,1)
		end	
	//end
end

-- Vehicles
-- Simfphys compatibility
function GM:PlayerButtonDown( ply, btn )
	numpad.Activate( ply, btn )
end
function GM:PlayerButtonUp( ply, btn )
	numpad.Deactivate( ply, btn )
end
-- When Hotfixing
local OldHarkonnenVtols = ents.FindByName("vtol_harkonnen")
for k, v in ipairs(OldHarkonnenVtols) do
	if(IsValid(v)) then
		v:Remove()
	end
end

local OldAtreidesVtols = ents.FindByName("vtol_atreides")
for k, v in ipairs(OldAtreidesVtols) do
	if(IsValid(v)) then
		v:Remove()
	end
end

local OldAtreidesAPCs = ents.FindByName("apc_atreides")
for k, v in ipairs(OldAtreidesAPCs) do
	if(IsValid(v)) then
		v:Remove()
	end
end

local OldHarkonnenAPCs = ents.FindByName("apc_atreides")
for k, v in ipairs(OldHarkonnenAPCs) do
	if(IsValid(v)) then
		v:Remove()
	end
end

-- Score Changer
function ManipScore(iTeam,iScore)
	if iTeam == 1 then
		ScoreAtreides = iScore
	elseif iTeam == 2 then
		ScoreHarkonnen = iScore
	end
	net.Start("ScoreManip")
		net.WriteInt(iTeam,32)
		net.WriteInt(iScore,32)
	net.Broadcast()
end
HarvesterWinners = {}
-- Capturing Net Messages

CapturingInProgress = {}
CapturingTable = {}


function WinHarvester(iTeam,iHarvester)
	HarvesterWinners[iHarvester] = iTeam
	HarvesterManip(iHarvester,iTeam)
	print("Harvester: "..iHarvester.." -- ".."Team: "..iTeam)
	Decapture(1,1)
end

function Capture(iTeam,iHarvester)
	net.Start("Capture")
		net.WriteInt(iTeam,32)
		net.WriteInt(iHarvester,32)
	net.Broadcast()
	timer.Stop("CaptureStarter"..iHarvester)
	timer.Create("CaptureStarter"..iHarvester, CVAR_CaptureTime:GetFloat(), 1, function()
		WinHarvester(iTeam,iHarvester)
	end)
end

function UpdateCaptureHUD(iTeam,tHarvester)

end

function Decapture(iTeam,iHarvester)
	net.Start("Decapture")
		net.WriteInt(iTeam,32)
		net.WriteInt(iHarvester,32)
	net.Broadcast()
end

function HarvesterManip(iTeam,iHarvester)
	net.Start("HarvesterManip")
		net.WriteInt(iHarvester,32)
		net.WriteInt(iTeam,32)
	net.Broadcast()
end

function ScanSpawnpoint(ply, vCorner1,radius1)
	local tEntities = ents.FindInSphere(vCorner1,radius1)
	local tPlayers = {}
	local iPlayers = 0
	
	for i = 1, #tEntities do
		if (tEntities[i]:IsPlayer() && tEntities[i] != ply ) then
			iPlayers = iPlayers + 1
			tPlayers[iPlayers] = tEntities[i]
		end
	end
	
	return tPlayers, iPlayers
end

function ScanHarvester(vCorner1,radius1)
	local tEntities = ents.FindInSphere(vCorner1,radius1)
	local tPlayers = {}
	local iPlayers = 0
	
	for i = 1, #tEntities do
		if ( tEntities[ i ]:IsPlayer() ) then
			iPlayers = iPlayers + 1
			tPlayers[ iPlayers ] = tEntities[ i ]
		end
	end
	
	return tPlayers, iPlayers
end

HarkonnenVtolEntIndexes = {}
AtreidesVtolEntIndexes = {}

AtreidesAPCEntIndexes = {}
HarkonnenAPCEntIndexes = {}

timer.Create("HarvesterScan",0.3,0,function()
	Scores = {
		ScoreAtreides,
		ScoreHarkonnen
	}
	if CVAR_Gamemode:GetInt() != 2 then return end

		-- B - 1
		for k,v in pairs(SPP) do
			local A1 = v
			local People1 = ScanHarvester(A1,1500)
			if People1[1] && People1[1]:Team() != HarvesterWinners[k] && People1[1]:Alive() && People1[1]:Health() > 0 then
				if People1[2] && People1[2]:Team() == HarvesterWinners[k] && People1[2]:Alive() && People1[2]:Health() > 0 then
					return
				end
				if CapturingInProgress[k] == 0 then
					CapturingInProgress[k] = 1
					CapturingTable[k] = People1[1]:Team()
					--PrintTable(CapturingTable)
					--UpdateCaptureHUD(People1[1]:Team(),CapturingTable)
					Capture(People1[1]:Team(),k)
				end
			else
				CapturingInProgress[k] = 0
				CapturingTable[k] = 0
				timer.Stop("CaptureStarter"..k)
			end
		end

		local Empties = 0
		for xk,xv in pairs(CapturingTable) do
			if xv < 1 then Empties = Empties + 1 end
		end
		if Empties == table.Count(SPP) then
			Decapture(1,1)
		end
end)



function SpawnVehiclesHarkonnen()
	local OldHarkonnenVtols = ents.FindByName("vtol_harkonnen")
	for k, v in ipairs(OldHarkonnenVtols) do
		if(IsValid(v)) then
			v:Remove()
		end
	end
	
	for k,v in pairs(SP_Vtols_Harkonnen) do
		local VTOL = ents.Create("lfs_crysis_vtol")
		VTOL:SetPos(v)
		VTOL:SetNWInt("vtol_spawnpoint", k)
		VTOL:SetName("vtol_harkonnen")
		VTOL:Spawn()
		VTOL:SetColor(Color(77,55,44))
		VTOL:SetAngles(Angle(0, -50, 0))
		HarkonnenVtolEntIndexes[k] = VTOL
	end
end

function MakeVtolAI()
	local AllVtols = ents.FindByClass("lfs_crysis_vtol")
	for k, v in ipairs(AllVtols) do
		if(IsValid(v)) && !v:GetDriver() then
			v:SetAI(true)
			v:SetAITEAM(3)
		end
	end

end
function SpawnVehiclesAtreides()
	local OldAtreidesVtols = ents.FindByName("vtol_atreides")
	for k, v in ipairs(OldAtreidesVtols) do
		if(IsValid(v)) then
			v:Remove()
		end
	end
	
	for k,v in pairs(SP_Vtols_Atreides) do
		local VTOL = ents.Create("lfs_crysis_vtol")
		VTOL:SetPos(v)
		VTOL:SetNWInt("vtol_spawnpoint", k)
		VTOL:SetName("vtol_atreides")
		VTOL:Spawn()
		VTOL:SetAngles(Angle(0, 170, 0))
		AtreidesVtolEntIndexes[k] = VTOL
	end
end

function RespawnVehiclesAtreides(vIndex)
	--sim_fphys_cogtank
	
	local OldAtreidesVtols = ents.FindByName("vtol_atreides")
	iCurAtreidesVtols = table.Count(OldAtreidesVtols)

	local OldAtreidesAPCs = ents.FindByName("apc_atreides")
	iCurAtreidesAPCs = table.Count(OldAtreidesAPCs)

	if !IsValid(AtreidesAPCEntIndexes[vIndex]) then
		local APC = simfphys.SpawnVehicleSimple("sim_fphys_conscriptapc_armed", SP_APC_Atreides[vIndex], Angle(0, 170, 0))
		APC:SetNWInt("apc_spawnpoint", k)
		APC:SetName("apc_atreides")
		AtreidesAPCEntIndexes[vIndex] = APC
	end

	if !IsValid(AtreidesVtolEntIndexes[vIndex]) then
		local VTOL = ents.Create("lfs_crysis_vtol")
		VTOL:SetPos(SP_Vtols_Atreides[vIndex])
		VTOL:SetNWInt("vtol_spawnpoint", k)
		VTOL:SetName("vtol_atreides")
		VTOL:Spawn()
		VTOL:SetAngles(Angle(0, 170, 0))
		AtreidesVtolEntIndexes[vIndex] = VTOL
	end
end

function RespawnVehiclesHarkonnen(vIndex)
	local OldHarkonnenVtols = ents.FindByName("vtol_harkonnen")
	iCurHarkonnenVtols = table.Count(OldHarkonnenVtols)

	local OldHarkonnenAPCs = ents.FindByName("apc_harkonnen")
	iCurHarkonnenAPCs = table.Count(OldHarkonnenAPCs)

	if !IsValid(HarkonnenAPCEntIndexes[vIndex]) then
		local APC = simfphys.SpawnVehicleSimple("sim_fphys_conscriptapc_armed", SP_APC_Harkonnen[vIndex], Angle(0, 170, 0))
		APC:SetNWInt("apc_spawnpoint", k)
		APC:SetName("apc_atreides")
		APC:SetColor(Color(155,122,111))
		HarkonnenAPCEntIndexes[vIndex] = APC
	end

	if !IsValid(HarkonnenVtolEntIndexes[vIndex]) then
		local VTOL = ents.Create("lfs_crysis_vtol")
		VTOL:SetPos(SP_Vtols_Harkonnen[vIndex])
		VTOL:SetNWInt("vtol_spawnpoint", k)
		VTOL:SetName("vtol_harkonnen")
		VTOL:Spawn()
		VTOL:SetColor(Color(77,55,44))
		VTOL:SetAngles(Angle(0, -50, 0))
		HarkonnenVtolEntIndexes[vIndex] = VTOL
	end
end

if timer.Exists("Dune_VehicleLoop") == false then
	timer.Create("Dune_VehicleLoop",11,0,function()
		for k,v in pairs(SP_Vtols_Atreides) do
			RespawnVehiclesAtreides(k)
		end
		for k,v in pairs(SP_Vtols_Harkonnen) do
			RespawnVehiclesHarkonnen(k)
		end
	end)
end


-- Spawning Spice Harvesters
function SpawnHarvesters()
	for k,v in pairs(SPH) do
		if IsValid(SPH[k]) then
			SPH[k]:Remove()
		end
	end
	for k,v in pairs(SPP) do
		SPH[k] = ents.Create("prop_thumper")
		SPH[k]:SetRenderMode(RENDERMODE_TRANSALPHA)
		SPH[k]:SetColor(Color(255,190,111,255))
		SPH[k]:SetAngles(Angle(0,0,0))
		SPH[k]:Fire("Enable")
		local Harvester = SPH[k]
		Harvester:SetModelScale(5, 0)
		Harvester:SetPos(v)
		Harvester:Activate()
		Harvester:Spawn()
		Harvester:SetNWInt("harvester_id",k)
		Harvester:SetSolid(2)
		Harvester:SetName("dune_spiceharvester")
		Harvester:SetMaterial("valk/crysis/vehicles/vtol/vtol_hull")
		Harvester:SetMoveType(MOVETYPE_NONE)
		CapturingInProgress[k] = 0
		PrintTable(CapturingInProgress)
	end
end

-- Second Sun
function SunMod()


end

function GM:PostGamemodeLoaded()
	timer.Simple(1,function() 
		SpawnVehiclesAtreides()
		SpawnVehiclesHarkonnen()
		SpawnHarvesters()
		SunMod()
	end)
	if timer.Exists("Dune_VehicleLoop") == false then
		timer.Create("Dune_VehicleLoop",3,0,function()
			for ix=1,3 do
				RespawnVehiclesAtreides(ix)
				RespawnVehiclesHarkonnen(ix)

			end
		end)
	end
	SpawnSpiceFog()	
end

function SpawnSpiceFog()
	-- Spice Smokestack
	if IsValid(Spicestack) then 
		Spicestack:Remove()
	end
	Spicestack = ents.Create("env_smokestack")
	Spicestack:SetKeyValue("SmokeMaterial","particle/smokesprites_0002.vmt")
	Spicestack:SetKeyValue("StartSize","12595")
	Spicestack:SetKeyValue("EndSize","13510")
	Spicestack:SetKeyValue("Rate","1")
	Spicestack:SetKeyValue("Speed","680")
	Spicestack:SetKeyValue("SpreadSpeed","11600")
	Spicestack:SetKeyValue("JetLength","14500")
	Spicestack:SetKeyValue("Twist","33")
	Spicestack:SetKeyValue("InitialState","1")
	Spicestack:SetKeyValue("rendercolor","222 222 165")
	Spicestack:SetKeyValue("renderamt","55")

	Spicestack:Spawn()
	Spicestack:Activate()
	Spicestack:SetPos(SpicePos)
	Spicestack:Fire("TurnOn")


	if IsValid(Spicestack2) then 
		Spicestack2:Remove()
	end
	/*
	Spicestack2 = ents.Create("env_smokestack")
	Spicestack2:SetKeyValue("SmokeMaterial","particle/particle_glow_05.vmt")
	Spicestack2:SetKeyValue("StartSize","155")
	Spicestack2:SetKeyValue("EndSize","65")
	Spicestack2:SetKeyValue("Rate","255")
	Spicestack2:SetKeyValue("Speed","555")
	Spicestack2:SetKeyValue("SpreadSpeed","11600")
	Spicestack2:SetKeyValue("JetLength","14500")
	Spicestack2:SetKeyValue("Twist","11")
	Spicestack2:SetKeyValue("InitialState","1")
	Spicestack2:SetKeyValue("rendercolor","255 255 255")
	Spicestack2:SetKeyValue("renderamt","255")

	Spicestack2:Spawn()
	Spicestack2:Activate()
	Spicestack2:SetPos(SpicePos)
	Spicestack2:Fire("TurnOn")
	*/
end

local SuicideFunnies = {
	"tried eating sand.",
	"wiped their ass with spice.",
	"thought he was a VTOL.",
	"didn't have the high ground.",
	"was unborn.",
	"thought he was in godmode.",
	"ate a shoe.",
	"paid a visit to heaven.",
	"got eaten by the gits.",
	"got run over by a Toyota Corolla."
}

-- DM Score
hook.Add("PlayerDeath", "DMScore", function(victim, inflictor, attacker)

	net.Start("PlyKill")
		net.WriteEntity(victim)
		if !attacker:IsVehicle() then
			net.WriteEntity(attacker)
		else
			net.WriteEntity(attacker:GetDriver())
		end
		net.WriteString(SuicideFunnies[math.random(#SuicideFunnies)])
	net.Broadcast()

	if CVAR_Gamemode:GetInt() != 1 || victim == attacker || !attacker:IsPlayer() then return end
	if attacker:Team() == 1 then
		ManipScore(1,ScoreAtreides+100)
	elseif attacker:Team() == 2 then
		ManipScore(2,ScoreHarkonnen+100)
	end

end)

-- Factions
function jAtreides( ply )
	ply:StripAmmo()
	ply:ExitVehicle()
	ply:StripWeapons()
    ply:SetTeam(1)
    ply:Spawn()
    --ChatAdd("TEAMCHANGE"," joined House Atreides!",{1,ply:Nick()})
end 
 
function jHarkonnen( ply )
	ply:StripAmmo()
	ply:ExitVehicle()
	ply:StripWeapons()
    ply:SetTeam(2)
    ply:Spawn()
   --ChatAdd("TEAMCHANGE"," joined House Harkonnen!",{2,ply:Nick()})
end 
function jAtreidesPLY( ply )
	ply:Kill()
	ply:StripAmmo()
	ply:ExitVehicle()
	ply:StripWeapons()
    ply:SetTeam(1)
    ply:Spawn()
    --ChatAdd("TEAMCHANGE"," joined House Atreides!",{1,ply:Nick()})
end 
 
function jHarkonnenPLY( ply )
	ply:Kill()
	ply:StripAmmo()
	ply:ExitVehicle()
	ply:StripWeapons()
    ply:SetTeam(2)
    ply:Spawn()
   --ChatAdd("TEAMCHANGE"," joined House Harkonnen!",{2,ply:Nick()})
end 

concommand.Add("dune_join_atreides", jAtreidesPLY)
concommand.Add("dune_join_harkonnen", jHarkonnenPLY)

function TestKill(ply)
	ply:Spawn()
	ply:Kill()
end

-- Chatlog Helper
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

-- Spawn
hook.Add("PlayerSpawn","Dune_Spawn",function(ply)
	if ply:Team() == 1 then
		Reposition1(ply)
		ply:SetEyeAngles(Angle(0, 170, 0))
	elseif ply:Team() == 2 then
		Reposition2(ply)
		ply:SetEyeAngles(Angle(0, -50, 0))
	end
end)

function Reposition1(ply)
	ply:SetPos(SP_Atreides[math.random(#SP_Atreides)])
	if ScanSpawnpoint(ply,ply:GetPos(),5)[1] then
		ply:SetPos(ply:GetPos()+Vector(math.random(-200, 200),math.random(-200, 200),100))
	end
end

function Reposition2(ply)
	ply:SetPos(SP_Harkonnen[math.random(#SP_Harkonnen)])
	if ScanSpawnpoint(ply,ply:GetPos(),5)[1] then
		ply:SetPos(ply:GetPos()+Vector(math.random(-200, 200),math.random(-200, 200),100))
	end
end

hook.Add("PlayerInitialSpawn","Dune_JL",function(ply)
	ChatAdd("JL"," joined the Battlefield! Rebalancing in 5 seconds.",ply:Nick())
	timer.Stop("DuneRebalanceAfterJoin")
	timer.Create("DuneRebalanceAfterJoin",5,1,function()
		Rebalance()
	end)
	ply:ConCommand("dune_team")
end)
local PInit = {}

function Rebalance()
	for k,v in pairs(player.GetAll()) do
		if AutoBalance() == 1 then
			jAtreides(v)
		else
			jHarkonnen(v)
		end
	end
end

gameevent.Listen("OnRequestFullUpdate")

hook.Add("OnRequestFullUpdate", "Dune_JL2", function(t)
	if not PInit[t.userid] then
		PInit[t.userid] = true
		Player(t.userid):SendLua([[SPlayAmbience()]])
		Player(t.userid).CanGrenade = true
		Player(t.userid):SendLua([[Player(]]..Player(t.userid):UserID()..[[).CanGrenade = true]])
		Player(t.userid):SendLua([[Abilities.GrenadeCoolBar = 1]])
	else
		return
	end
end)


function GM:PlayerShouldTakeDamage(ply,attacker)
	return attacker:GetClass() == "npc_grenade_frag" || ply == attacker || attacker:IsPlayer() && ply:Team() != attacker:Team() || attacker:IsVehicle() && ply:Team() != attacker:GetDriver():Team()
end
function GM:PlayerSetModel(ply)
	if ply:Team() != 1 && ply:Team() != 2 then 
		ply:SetModel("models/effects/teleporttrail_alyx.mdl")
		ply:SetPos(Vector(0,0,-31110))
		--ply:Lock()
	end
	Atreides_PlyMDL = "models/player/swat.mdl"
	Harkonnen_PlyMDL = "models/ninja/rage_enforcer.mdl"
	--Aleph_PlyMDL = "models/tsbb/animals/asian_elephant.mdl"

	if ply:Team() == Atreides then
		ply:Give("tfa_kf2_katana") --melee sword
	    ply:Give("tfa_bcry2_nova") --pistol
	    ply:Give("tfa_bcry2_fy71") --rifle
	    ply:Give("tfa_bcry2_gauss") --sniper
	    ply:Give("tfa_bcry2_hmg") --heavy
	    --ply:GiveAmmo(32, "357")
	    ply:SetModel(Atreides_PlyMDL)
	    TFAUpdateAttachments()
	elseif ply:Team() == Harkonnen then
	    ply:Give("tfa_kf2_pulverizer") --melee hammer
	    ply:Give("tfa_bcry2_gauss") --sniper
	    ply:Give("tfa_bcry2_hammer") --pistol
	  	ply:Give("tfa_bcry2_hmg") --heavy
	  	ply:Give("tfa_bcry2_fy71") -- rifle without loop glitch til fix
	    --ply:Give("tfa_bcry2_scar") --rifle
	    --ply:GiveAmmo(32, "357")
	    --if CVAR_Aleph:GetInt() != 1 then
	    	--ply:SetModel(Harkonnen_PlyMDL)
		--else
			--ply:SetModel(Aleph_PlyMDL)
		--end
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

-- Round End
function WinRound(iTeam)
	RoundHasEnded = 1
	BroadcastLua("WinRound("..iTeam..")")
	timer.Simple(7,function()
		game.ConsoleCommand("changelevel " .. "gm_disten" ..  "\n")
	end)
end

-- Spice Counter
timer.Create("SP_Countspice",0.5,0,function()
	if RoundHasEnded == 1 then return end
	local SpiceProduction = {0,0}
	for k,v in pairs(HarvesterWinners) do
		if v == 1 then
			if SpiceProduction[v] == 0 then 
				SpiceProduction[v] = 5
			else
				SpiceProduction[v] = SpiceProduction[v] *2
			end
			if Scores[v] < 5000 then
				ManipScore(v,Scores[v]+SpiceProduction[v])
			else
				Scores[v] = 5000
				WinRound(1)
			end
		end
		if v == 2 then
			if SpiceProduction[v] == 0 then 
				SpiceProduction[v] = 5
			else
				SpiceProduction[v] = SpiceProduction[v] *2
			end
			if Scores[v] < 5000 then
				ManipScore(v,Scores[v]+SpiceProduction[v])
			else
				Scores[v] = 5000
				WinRound(2)
			end
		end
	end
end)

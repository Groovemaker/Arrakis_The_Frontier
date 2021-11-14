-- Serverside
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
-- When Hotfixing, tell people
BroadcastLua([[chat.AddText(Color(255,155,50),"[Arrakis: The Frontier]: ",Color(111,155,255),"init.lua ",Color(255,255,255),"reloaded!")]])

-- Netstrings
util.AddNetworkString("ScoreManip")
util.AddNetworkString("Capture")
util.AddNetworkString("Decapture")
util.AddNetworkString("HarvesterManip")

-- Resources
resource.AddFile("materials/atreides.png")
resource.AddFile("materials/harkonnen.png")
resource.AddFile("materials/ability_grenade.png")
resource.AddFile("sound/arrakis_credits.mp3")
resource.AddFile("sound/arrakis_ambience.wav")
resource.AddFile("sound/grenade_recharged.wav")

-- Spice Points
SPP = {
	Vector(-2523.754150, 3018.725342, -10246.272461),
	Vector(-3459.514648, -3145.623535, -9957.653320)
}
SPH = {}


-- Set Skyname
RunConsoleCommand("sv_skyname", "sky_day01_06")

-- Disable C Menu of TFA
RunConsoleCommand("sv_tfa_cmenu",0)

-- Set up CVARs
CVAR_CaptureTime = CreateConVar( "dune_sv_capture_time", "5", FCVAR_NONE+FCVAR_NOTIFY, "Time needed to capture harvesters", 0.01)
CVAR_GrenadeCooldown = CreateConVar( "dune_sv_grenade_cooldown", "7", FCVAR_NONE+FCVAR_NOTIFY, "The lower, the faster the Grenade recharges", 0.01)
CVAR_ShieldInterval = CreateConVar( "dune_sv_recharge_interval", "0.1", FCVAR_NONE+FCVAR_NOTIFY, "The lower, the faster the shield recharges", 0.01)
CVAR_ShieldDelay = CreateConVar( "dune_sv_recharge_delay", "1", FCVAR_NONE+FCVAR_NOTIFY, "The lower, the sooner the shield starts recharging", 0.1)
CVAR_Gamemode = CreateConVar( "dune_sv_gamemode", "1", FCVAR_NONE+FCVAR_NOTIFY, "1 - DM; 2 - Spice Harvest", 1,2)

-- Loadout
function GM:PlayerLoadout(ply)
	ply:SetArmor(100)
	return true
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

function HarvesterManip(iTeam,iCount)
	net.Start("HarvesterManip")
		net.WriteInt(iTeam,32)
		net.WriteInt(iCount,32)
	net.Broadcast()
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
				table.remove(CapturingTable,k)
				timer.Stop("CaptureStarter"..k)
			end
		end
		if table.IsEmpty(CapturingTable) then
			Decapture(1,1)
		end
end)

-- Spawners
SP_Vtols_Harkonnen = {
	Vector(-12988.833984, 10670.055664, -9034.481445),
	Vector(-11978.709961, 10691.329102, -9012.096680),
	Vector(-11006.250000, 11011.807617, -8930.311523),
}

SP_Vtols_Atreides = {
	Vector(11965.055664, -6706.582520, -9968.274414),
	Vector(11477.743164, -7800.555176, -9969.972656),
	Vector(12658.222656, -8133.210938, -9965.285156),
}

SP_APC_Atreides = {
	Vector(11891.732422, -6082.339355, -10317.850586),
	Vector(12891.853516, -6182.138184, -10342.645508),
	Vector(14891.222656, -8282.210938, -9935.285156),
}

SP_APC_Harkonnen ={
	Vector(-12966.287109, 12066.671875, -9060.109375),
	Vector(-12759.865234, 11695.660156, -9118.357422),
	Vector(-12230.449219, 11506.187500, -9137.444336),
}

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
		local APC = simfphys.SpawnVehicleSimple("sim_fphys_tank_cell_apc", SP_APC_Atreides[vIndex], Angle(0, 170, 0))
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
		local APC = simfphys.SpawnVehicleSimple("sim_fphys_tank_cell_apc", SP_APC_Harkonnen[vIndex], Angle(0, 170, 0))
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

timer.Create("Dune_VehicleLoop",11,0,function()
	for k,v in pairs(SP_Vtols_Atreides) do
		RespawnVehiclesAtreides(k)
	end
	for k,v in pairs(SP_Vtols_Harkonnen) do
		RespawnVehiclesHarkonnen(k)
	end
end)

-- Spawning Spice Harvesters
function SpawnHarvesters()
	for k,v in pairs(SPP) do
		if IsValid(SPH[k]) then
			SPH[k]:Remove()
		end
	end
	for k,v in pairs(SPP) do
		SPH[k] = ents.Create("prop_thumper")
		SPH[k]:SetRenderMode(RENDERMODE_TRANSALPHA)
		SPH[k]:SetColor(Color(255,255,255,255))
		SPH[k]:SetAngles(Angle(0,-120,0))
		SPH[k]:Fire("Enable")
		SPH[k]:SetSolid(1)
		local Harvester = SPH[k]
		Harvester:SetModelScale(5, 0)
		Harvester:SetPos(v)
		Harvester:Spawn()
		CapturingInProgress[k] = 0
		PrintTable(CapturingInProgress)
	end
end

function GM:PostGamemodeLoaded()
	timer.Simple(1,function() 
		SpawnVehiclesAtreides()
		SpawnVehiclesHarkonnen()
		SpawnHarvesters()
	end)
	timer.Create("Dune_VehicleLoop",3,0,function()
		for ix=1,3 do
			RespawnVehiclesAtreides(ix)
			RespawnVehiclesHarkonnen(ix)
		end
	end)
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
	Spicestack:SetKeyValue("rendercolor","222 222 188")
	Spicestack:SetKeyValue("renderamt","87")

	Spicestack:Spawn()
	Spicestack:Activate()
	Spicestack:SetPos(Vector(0, 0, -9000))
	Spicestack:Fire("TurnOn")
end

-- DM Score
hook.Add("PlayerDeath", "DMScore", function(victim, inflictor, attacker)
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

concommand.Add( "dune_join_atreides", jAtreides )
concommand.Add( "dune_join_harkonnen", jHarkonnen )

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
	SP_Atreides = {
		Vector(12408.885742, -7528.326660, -10543.968750),
		Vector(12517.307617, -7696.805176, -10551.283203),
		Vector(12313.879883, -8009.676758, -10550.638672),
		Vector(11923.995117, -7815.384766, -10501.597656),
		Vector(11804.260742, -7461.417969, -10472.499023),
		Vector(11974.820313, -7199.516602, -10497.281250),

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
		ply:SetPos(table.Random(SP_Atreides))
		ply:SetEyeAngles(Angle(0, 170, 0))
	elseif ply:Team() == 2 then
		ply:SetPos(table.Random(SP_Harkonnen))
		ply:SetEyeAngles(Angle(0, -50, 0))
	end
end)

hook.Add("PlayerInitialSpawn","Dune_JL",function(ply)
	ChatAdd("JL"," joined the Battlefield!",ply:Nick())
	ply:ConCommand("dune_team")
end)
local PInit = {}

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

-- Spice Counter
timer.Create("SP_Countspice",0.5,0,function()
	if HarvesterWinners[1] == 1 || HarvesterWinners[1] == 2 then
		if Scores[HarvesterWinners[1]] < 5000 then
			ManipScore(HarvesterWinners[1],Scores[HarvesterWinners[1]]+5)
		else

		end
	end
	if HarvesterWinners[2] == 1 || HarvesterWinners[2] == 2 then
		if Scores[HarvesterWinners[2]] < 5000 then
			ManipScore(HarvesterWinners[2],Scores[HarvesterWinners[2]]+5)
		else

		end
	end
end)

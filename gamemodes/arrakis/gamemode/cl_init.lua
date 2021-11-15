-- Clientside
include("shared.lua")

function SPlayAmbience()
	surface.PlaySound("arrakis_ambience.wav")
end

-- Thanks to slownls
DPANELBlurMat = Material("pp/blurscreen")
DPANELBlurMat2 = Material("pp/blurscreen")

function PanelDrawBlur(panel, amount) 
	local tx, ty = panel:LocalToScreen(0, 0) 
	local scrW, scrH = ScrW(), ScrH() 
	surface.SetDrawColor(255, 255, 255) 
	surface.SetMaterial(DPANELBlurMat) 
	for i = 1, 3 do 
		DPANELBlurMat:SetFloat("$blur", (i / 3) * (amount or 6)) 
		DPANELBlurMat:Recompute() 
		render.UpdateScreenEffectTexture() 
		surface.DrawTexturedRect(tx * -1, ty * -1, scrW, scrH) 
	end
end

function DunePaint_DFrame(w,h)
	draw.RoundedBox(1, 0, 0, w, h, Color(0,0,0,222))
end

function D_JAtreides()
	RunConsoleCommand("dune_join_atreides")
	TeamFrame:Close()
end

function D_JHarkonnen()
	RunConsoleCommand("dune_join_harkonnen")
	TeamFrame:Close()
end

function set_team() 
	TeamFrame = vgui.Create("DFrame") 
	TeamFrame:SetPos(0, 0)
	TeamFrame:SetSize( ScrW(), ScrH() )
	TeamFrame:SetTitle("")
	TeamFrame:SetVisible(true) 
	TeamFrame:SetDraggable(false) 
	TeamFrame:ShowCloseButton(false) 
	TeamFrame:MakePopup() 
	InMenu = true
	local html = vgui.Create("DHTML", TeamFrame)
	html:Dock(FILL)

	-- Atreides Logo | https://i.imgur.com/OzBDqi0.png | Outlined: https://i.imgur.com/SY2LcM7.png
	-- Harkonnen Logo | https://i.imgur.com/HGv0kj7.png | Outlined:  https://i.imgur.com/oSyzntH.png

	html:SetHTML([[
		<link rel="preconnect" href="https://fonts.googleapis.com">
		<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
		<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap" rel="stylesheet">
		<style>
			#title {
				color: white;
				font-size: 50px;
				font-family:'Orbitron', sans-serif;
				display: flex;
			}
			#header {
				color: white;
				font-family:'Orbitron', sans-serif;
				display: flex;
			}
			#housedescription {
				color: white;
				font-family:'Orbitron', sans-serif;
				display: flex;
			}
			#banner {
				width: 14%;
				display: flex;

			}
			#line {
				border-top: 3px solid #bbb;
				margin-bottom: 4%;
				display: flex;
			}
			#outer {
			  width:100%;
			  display: flex;
			  justify-content: center;
			  align-items: center;
			  text-align: center;
			}
		</style>
		<div id="outer">
			<h1 id="title" style="">Choose your Heritage!</h1>
			<div id="line"></div>
			<a onclick='console.log("RUNLUA:D_JAtreides()")'>
				<img id="banner" src="https://i.imgur.com/SY2LcM7.png"></img>
				<h2 id="header">House Atreides</h2>
				<h3 id="header">Came to Arrakis to mine spice after being granted stewardship by the emperor</h3>
			</a>
			<a onclick='console.log("RUNLUA:D_JHarkonnen()")'>
				<img id="banner" src="https://i.imgur.com/oSyzntH.png"></img>
				<h2 id="header">House Harkonnen</h2>
				<h3 id="header">Fierce, ruthless warriorkin whom are House Atreides' sworn enemies</h3>
			</a>
		</div>
		<script>
			document.getElementById("Atreides").onclick = function() {
				console.log("RUNLUA:D_JAtreides()")
			}
		</script>
	]])

	html:SetAllowLua(true)
	function TeamFrame:OnClose()
		InMenu = false
	end
 	function TeamFrame:Paint(w,h)
 		PanelDrawBlur(self, 5)
 		DunePaint_DFrame(w,h)
 	end
end 

concommand.Add("dune_team", set_team)
concommand.Add("dune_credits", credits)





-- HUD
if not CLIENT then return end
local trace2ent = nil
	InMenu = false
local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then return false end

	-- Don't return anything here, it may break other addons that rely on this hook.
end )

local function SunBeamMod()
	if ( !render.SupportsPixelShaders_2_0() ) then return end

	local sun = util.GetSunInfo()

	if ( !sun ) then return end
	if ( sun.obstruction == 0 ) then return end

	local sunpos = EyePos() + sun.direction * 4096
	local scrpos = sunpos:ToScreen()

	local dot = ( sun.direction:Dot( EyeVector() ) - 0.8 ) * 5
	if ( dot <= 0 ) then return end
	DrawSunbeams( 0.6, 0.4 * dot * sun.obstruction, 0.15, scrpos.x / ScrW(), scrpos.y / ScrH() )
end
local function GraphicsModding()
	local mat_dunevision = Material("engine/singlecolor")
	mat_dunevision:SetFloat( "$alpha", 0 )
	local colormod_day2 = {
	    ["$pp_colour_addr"] = 0.1,
	    ["$pp_colour_addg"] = 0.1,
	    ["$pp_colour_addb"] = 0,
	    ["$pp_colour_brightness"] = -0.03,
	    ["$pp_colour_contrast"] = 0.7,
	    ["$pp_colour_colour"] = 1,
	    ["$pp_colour_mulr"] = 0,
	    ["$pp_colour_mulg"] = 0,
	    ["$pp_colour_mulb"] = 0
	}
	local colormod_day = {
	    ["$pp_colour_addr"] = 0.05,
	    ["$pp_colour_addg"] = 0.05,
	    ["$pp_colour_addb"] = 0.01,
	    ["$pp_colour_brightness"] = 0.01,
	    ["$pp_colour_contrast"] = 0.6,
	    ["$pp_colour_colour"] = 1.5,
	    ["$pp_colour_mulr"] = 0.3,
	    ["$pp_colour_mulg"] = 0.3,
	    ["$pp_colour_mulb"] = 0
	}
	local colormod_night = {
	    ["$pp_colour_addr"] = 0.02,
	    ["$pp_colour_addg"] = 0.01,
	    ["$pp_colour_addb"] = 0.03,
	    ["$pp_colour_brightness"] = 0,
	    ["$pp_colour_contrast"] = 0.17,
	    ["$pp_colour_colour"] = 1.4,
	    ["$pp_colour_mulr"] = 0.2,
	    ["$pp_colour_mulg"] = 0.1,
	    ["$pp_colour_mulb"] = 0.3,
	}

		    
    if BD_RENDERING_RTWORLD then return end
    render.UpdateScreenEffectTexture()

    Day = CVAR_DAYNIGHT:GetInt()

    if Day == 1 then
    	SunBeamMod()
    	DrawColorModify(colormod_day)
    	DrawBloom( 0.5, 1.1, 9, 9, 1, 1, 1, 1, 1 )
    else
    	DrawColorModify(colormod_night)
    end

end

function DSetupWorldFog()

	render.FogMode( MATERIAL_FOG_LINEAR )
	render.FogStart( 0 )
	render.FogEnd( 4000 )
	render.FogMaxDensity(0.55)

	local col = Vector( 1, 1, 0.95 )
	render.FogColor( col.x * 255, col.y * 255, col.z * 255 )

	return true

end

function DSetupSkyFog(skyboxscale)

	render.FogMode( MATERIAL_FOG_LINEAR )
	render.FogStart( 0 * skyboxscale)
	render.FogEnd( 0 * skyboxscale )
	render.FogMaxDensity(0.55)

	local col = Vector( 1, 1, 0.95 )
	render.FogColor( col.x * 255, col.y * 255, col.z * 255 )

	return true

end

hook.Add( "SetupWorldFog", "fog1", DSetupWorldFog )
hook.Add( "SetupSkyboxFog", "fog2", DSetupSkyFog )

hook.Add("RenderScreenspaceEffects", "DuneGraphicsModifier", function()
	GraphicsModding()
end)
DOF_Kill()
local GM = GM or GAMEMODE or gmod.GetGamemode()
function DrawToyTown()
	print("0")
end


local hud_deathnotice_time = CreateConVar( "hud_deathnotice_time", "6", FCVAR_REPLICATED )
local Deaths = {}



surface.CreateFont("Killfeed1",{
	font = "ChatFont",
	extended = false,
	size = 20,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})

local Deaths = {}
local SuicideFunnies = {
	"tried eating sand.",
	"wiped their ass with spice.",
	"thought he was a VTOL.",
	"didn't have the high ground.",
	"was unborn.",
	"thought he was in godmode."
}
net.Receive("PlyKill", function()
	local Tbl = {}
	Tbl.Victim = net.ReadEntity()
	Tbl.Player = net.ReadEntity()
	Tbl.Col = team.GetColor(Tbl.Player:Team())
	Tbl.Text = "killed"
	Tbl.Time = CurTime()
	Tbl.Suicide = 0
	
	if Tbl.Victim == Tbl.Player then
		Tbl.Suicide = 1
		Tbl.Text = SuicideFunnies[math.random(#SuicideFunnies)]
	end

	table.insert( Deaths, Tbl )
end)


function GM:DrawDeathNotice( x, y )
	local hud_deathnotice_time = hud_deathnotice_time:GetFloat()
	
	x = ScrW() / 12
	--y = y * ScrH()
	y = ScrH()*0.3
	
	for k, Death in pairs( Deaths ) do
		if ( Death.Time + hud_deathnotice_time > CurTime() ) then
			if ( Death.lerp ) then
				--x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
			end
			
			Death.lerp = Death.lerp or {}
			Death.lerp.x = x
			Death.lerp.y = y
			
			surface.SetFont( "Killfeed1" )
			Death.w, Death.h = surface.GetTextSize( Death.Text )
			
			local fadeout = ( Death.Time + hud_deathnotice_time ) - CurTime()
			
			local alpha = math.Clamp( fadeout * 255, 0, 255 )
			
			local ACol = team.GetColor(Death.Player:Team())
			local TCol = team.GetColor(Death.Victim:Team())
			ACol.a = alpha
			TCol.a = alpha
			
			if Death.Suicide == 0 then
				draw.SimpleText(Death.Player:Nick(), "Killfeed1", x - 61, y, ACol, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				draw.SimpleText(Death.Text, "Killfeed1", (x - 60) + (surface.GetTextSize(Death.Player:Nick())*1.07), y, Color( 255, 255, 255, alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				draw.SimpleText(Death.Victim:Nick(), "Killfeed1", (x - 60) + ((surface.GetTextSize(Death.Text)+surface.GetTextSize(Death.Player:Nick()))*1.1), y, TCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			else
				draw.SimpleText(Death.Player:Nick(), "Killfeed1", x - 61, y, ACol, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				draw.SimpleText(Death.Text, "Killfeed1", (x - 60) + (surface.GetTextSize(Death.Player:Nick())*1.07), y, Color( 255, 255, 255, alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			end
		
			y = y + Death.h * 1.25
		end
	end
	
	for k, Death in pairs( Deaths ) do
		if ( Death.Time + hud_deathnotice_time > CurTime() ) then
			return
		end
	end
	
	Deaths = {}
end
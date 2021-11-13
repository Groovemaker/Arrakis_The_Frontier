-- Clientside
include("shared.lua")

function PlayAmbience()
	sound.PlayFile("sound/arrakis_ambience.wav", "noblock", function(station,erid,err)
		Ambience = station
		if (IsValid(Ambience)) then
			Ambience:SetVolume(0.4)
			Ambience:Play()
		end
	end )
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
surface.CreateFont( "EXPFont", {
	font = "Helvetica", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 100,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "LVLFont", {
	font = "Helvetica", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 20,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "MoneyFont", {
	font = "Helvetica", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 30,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
surface.CreateFont( "NameFont", {
	font = "Helvetica", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 25,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )
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
	    ["$pp_colour_addr"] = 0.1,
	    ["$pp_colour_addg"] = 0.05,
	    ["$pp_colour_addb"] = 0.13,
	    ["$pp_colour_brightness"] = -0.04,
	    ["$pp_colour_contrast"] = 0.1,
	    ["$pp_colour_colour"] = 1.4,
	    ["$pp_colour_mulr"] = 1.1,
	    ["$pp_colour_mulg"] = 1,
	    ["$pp_colour_mulb"] = 2,
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



hook.Add("RenderScreenspaceEffects", "DuneGraphicsModifier", function()
	GraphicsModding()
end)
DOF_Kill()
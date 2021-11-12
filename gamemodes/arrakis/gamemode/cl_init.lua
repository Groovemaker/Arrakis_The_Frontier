-- Clientside
include("shared.lua")

-- Thanks to slownls
DPANELBlurMat = Material("pp/blurscreen")
function PanelDrawBlur(panel, amount) 
	local x, y = panel:LocalToScreen(0, 0) 
	local scrW, scrH = ScrW(), ScrH() 
	surface.SetDrawColor(255, 255, 255) 
	surface.SetMaterial(DPANELBlurMat) 
	for i = 1, 3 do 
		DPANELBlurMat:SetFloat("$blur", (i / 3) * (amount or 6)) 
		DPANELBlurMat:Recompute() 
		render.UpdateScreenEffectTexture() 
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH) 
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
	TeamFrame:ShowCloseButton(true) 
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
function credits() 
	CreditsFrame = vgui.Create("DFrame") 
	CreditsFrame:SetPos(0, 0)
	CreditsFrame:SetSize( ScrW(), ScrH() )
	CreditsFrame:SetTitle("")
	CreditsFrame:SetVisible(true) 
	CreditsFrame:SetDraggable(false) 
	CreditsFrame:ShowCloseButton(true) 
	CreditsFrame:MakePopup() 

	local html = vgui.Create("DHTML", CreditsFrame)

	html:Dock(FILL)

	html:SetHTML([[
		<link rel="preconnect" href="https://fonts.googleapis.com">
		<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
		<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap" rel="stylesheet">
		<style>
		body {
		  background: #000;
		  color: #fff;
		  font-family:'Orbitron', sans-serif;
		  line-height: 1;
		  margin: 0;
		  padding: 0;
		  overflow: hidden;
		}

		ul li {
		    list-style: none;
		}

		.container {
		  margin: 0 auto;
		  height: auto;
		  width: 100%;
		  text-align: center;
		}

		.credits {
		  margin: 0 40%;
		  -moz-transform: translateY(100%);
		  -webkit-transform: translateY(100%);
		  transform: translateY(100%);
		  
		  -moz-animation: movenames 55s linear infinite;
		  -webkit-animation: movenames 55s linear infinite;
		  animation: movenames 55s linear infinite;
		}
		.credits span {
		  display: block;
		  margin: 0 0 15em;
		  width: 100%;
		}
		#image1 {
		   display: block;
		   width: 100%;
		}
		/* for Firefox */
		@-moz-keyframes movenames {
		  from { -moz-transform: translateY(31%); }
		  to { -moz-transform: translateY(-100%); }
		}

		/* for Chrome */
		@-webkit-keyframes movenames {
		  from { -webkit-transform: translateY(31%); }
		  to { -webkit-transform: translateY(-100%); }
		}

		@keyframes movenames {
		  from {
		    -moz-transform: translateY(31%);
		    -webkit-transform: translateY(31%);
		    transform: translateY(31%);
		  }
		  to {
		    -moz-transform: translateY(-100%);
		    -webkit-transform: translateY(-100%);
		    transform: translateY(-100%);
		  }
		}
		</style>
		<div class="container">
    		<div class="credits">
    			<img id="image1" src="https://i.imgur.com/kBVrgZe.png"></img>
    			<h2>A Tribute to DUNE</h2>
	    		<h3>A Fan Game By</h3>
	    		<span>Runic</span>
	    		<h3>Featuring Addons powered by</h3>
	    		<span>TFA<br /><br />
	    		LFS<br /><br />
	    		</span>
	    		<h3>As well as Addons by</h3>
	    		<span>
	    		Cole<br /><br />
	    		NextKurome76TheSoldier<br /><br />
	    		</span>
	    		<h3>Snippets and additions by</h3>
	    		<span>slownls</span>
	    		<h3>Featuring Music and Sounds by</h3>
	    		<span>ash19 - Land of Twists</span>
	    		<h3>Special thanks to the testers</h3>
	    		<span>
	    		Tzucas<br /><br />
	    		</span>
	    		<h3>Special thanks as well to</h3>
	    		<span>
	    		Naki<br /><br />
	    		My buddies at work<br /><br />
	    		Mom & Dad<br /><br />
	    		SpookyFM<br /><br />
	    		Katsu, for some math basics<br /><br />
	    		</span>
	    		<br /><br /><br />
	    		<h1>And YOU, for playing!</h1>
    		</div>
		</div>
	]])

	sound.PlayURL ("https://raw.githubusercontent.com/Groovemaker/Arrakis_The_Frontier/main/gamemodes/arrakis/credits.mp3", "noblock", function(station)
		CredSnd = station
		if (IsValid(CredSnd)) then
			CredSnd:Play()
		end
	end )
	html:SetAllowLua(true)

	 function CreditsFrame:Paint(w,h)
 		draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,255))
 	end

 	function CreditsFrame:OnClose()
 		CredSnd:Stop()
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
	    ["$pp_colour_addb"] = 0,
	    ["$pp_colour_brightness"] = -0.03,
	    ["$pp_colour_contrast"] = 0.65,
	    ["$pp_colour_colour"] = 1.4,
	    ["$pp_colour_mulr"] = 1,
	    ["$pp_colour_mulg"] = 1,
	    ["$pp_colour_mulb"] = 1
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
    	DrawColorModify(colormod_day)
    	DrawBloom( 0.85, 2.3, 9, 9, 1, 1, 1, 1, 1 )
    else
    	DrawColorModify(colormod_night)
    end
    
    --DrawBloom( number Darken, number Multiply, number SizeX, number SizeY, number Passes, number ColorMultiply, number Red, number Green, number Blue )
    
end
hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()
	if (InMenu == true) then return end
	function GetAmmoForCurrentWeapon( ply )
		if ( !IsValid( ply ) ) then return -1 end

		local wep = ply:GetActiveWeapon()
		if ( !IsValid( wep ) ) then return -1 end
	 	manastuff = wep:Clip1() * 5.6
		return manastuff
	end
	function GetMax( ply )
		if ( !IsValid( ply ) ) then return -1 end

		local wep = ply:GetActiveWeapon()
		if ( !IsValid( wep ) ) then return -1 end
	 	maxclip = wep:GetMaxClip1()
		return maxclip
	end

	local HP = LocalPlayer():Health()
	local Ammo = GetAmmoForCurrentWeapon(LocalPlayer())

	if(HP > 100) then HP = 100 end
	if(Ammo == nil) then Ammo = 0 end
	if(Ammo < 1) then Ammo = 0 end
	if(Ammo >= 100) then Ammo = 100 end

	local Armor = LocalPlayer():Armor()
	if(Armor > 100) then Armor = 100 end



	surface.SetFont( "EXPFont" )
	surface.SetTextColor( 255, 255, 255 )
	surface.SetTextPos( ScrW() / 10, ScrH() / 1.21 )
	--surface.DrawText( "+" )



	--Health Bar
	draw.RoundedBox( 4, ScrW() / 5.5, ScrH() / (1.1*35), ScrW() / 1.6, ScrH() / 55, Color(1,1,1,100) )
	draw.RoundedBox( 6, ScrW() / 5.45, ScrH() / (1.025*35), ScrW() * HP / 161, ScrH() / 73.5, Color(255, 255, 255, 100) )	

	--Shield Bar
	draw.RoundedBox( 6, ScrW() / 5.45, ScrH() / (1.025*35), ScrW() * Armor / 161, ScrH() / 73.5, Color(111, 155, 255, 155) )


	-- main body
	/*
	draw.RoundedBox( 2, ScrW() / 60.08, ScrH() / 21, ScrW() / 4.6, ScrH() / 19 , Color(30,30,30,155) )



	draw.RoundedBox( 0, ScrW() / 19.08 , ScrH() / 13, ScrW() * 100 / 709, ScrH() / 260, Color(130, 100, 0, 105) )

	draw.RoundedBox( 0, ScrW() / 19.08 , ScrH() / 13, ScrW() * HP / 709, ScrH() / 260, Color(255, 200, 0, 155) )
	draw.RoundedBox( 0, ScrW() / 19.08 , ScrH() / 11.8, ScrW() * 100 / 709, ScrH() / 260, Color(0, 100, 30, 105) )
	draw.RoundedBox( 0, ScrW() / 19.08 , ScrH() / 11.8, ScrW() * Ammo / 709, ScrH() / 260, Color(0, 255, 100, 155) )

	
	surface.SetFont( "NameFont" )
	surface.SetTextColor( 255, 255, 255 )
	surface.SetTextPos( ScrW() / 20.08, ScrH() / 19 )
	surface.DrawText( "".. LocalPlayer():Nick())

	surface.SetFont( "LVLFont" )
	surface.SetTextColor( 255, 255, 255 )
	surface.SetTextPos( ScrW() / 5.9, ScrH() / 18.1 )
	surface.DrawText( "TEAM")

	-- team icon
	surface.SetDrawColor(Color(255,255,255,255))
	if LocalPlayer():Team() == 1 then -- atreides
		surface.SetMaterial(Material("gui/progress_cog.png"))
	elseif LocalPlayer():Team() == 2 then -- harkonnen
		surface.SetMaterial(Material("gui/progress_cog.png"))
	end
	surface.DrawTexturedRect( ScrW() / 53.08, ScrH() / 19, ScrW() / 45, ScrH() / 30, Color(255, 255, 255, 255) )
	*/
end )

hook.Add("RenderScreenspaceEffects", "DuneGraphicsModifier", function()
	GraphicsModding()
end)
DOF_Kill()
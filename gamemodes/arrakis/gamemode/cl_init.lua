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
	draw.RoundedBox(1, 0, 0, w, h, Color(44,44,44,222))
end

function D_JAtreides()
	RunConsoleCommand("dune_join_atreides")
	RunConsoleCommand("dune_class")
	TeamFrame:Close()
end

function D_JHarkonnen()
	RunConsoleCommand("dune_join_harkonnen")
	RunConsoleCommand("dune_class")
	TeamFrame:Close()
end

function D_SetClass(ClassId)
	RunConsoleCommand("dune_setclass",tostring(ClassId))
	ClassFrame:Close()
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

	-- Atreides Logo | https://i.imgur.com/OzBDqi0.png | Outlined: https://i.imgur.com/SY2LcM7.png | Banner: https://i.imgur.com/KXKOpgk.png
	-- Harkonnen Logo | https://i.imgur.com/HGv0kj7.png | Outlined:  https://i.imgur.com/oSyzntH.png | Banner: https://i.imgur.com/miSfIdb.png

	html:SetHTML([[
		<link rel="preconnect" href="https://fonts.googleapis.com">
		<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
		<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap" rel="stylesheet">
		<style>
			html {
				overflow: hidden;
			}
			#title {
				text-align: center;
				color: white;
				font-size: 50px;
				font-family:'Orbitron', sans-serif;
			}
			#header1 {
				font-size: 40px;
				margin-bottom: 5%;
				color: white;
				font-family:'Orbitron', sans-serif;
			}
			#header2 {
				margin-bottom: 5%;
				color: white;
				font-family:'Orbitron', sans-serif;
			}
			#housedescription {
				color: white;
				font-family:'Orbitron', sans-serif;
			}
			#banner {
				width: 30%;
			}
			#line {
				border-top: 3px solid #bbb;
				margin-bottom: -4%;
			}
			#maincontainer{
				display: flex;  
      			flex-direction: row;
			}
			#outer {
				margin: 5%;
				float:left;
				width: 40%;
				justify-content: center;
				align-items: center;
				text-align: center;
			}
			#outer2 {
				float:left;
				width: 40%;
				justify-content: center;
				align-items: center;
				text-align: center;
			}
		</style>
		<h1 id="title" style="">Choose your Heritage!</h1>
		<div id="line"></div>
		<div id="outer">
			<a onclick='console.log("RUNLUA:D_JAtreides()")'>
				<h2 id="header1">House Atreides</h2>
				<img id="banner" src="https://i.imgur.com/KXKOpgk.png"></img>
				<h3 id="header2">Came to Arrakis to mine spice after being granted stewardship by the emperor</h3>
			</a>
		</div>
		<div id="outer">
			<a onclick='console.log("RUNLUA:D_JHarkonnen()")'>
				<h2 id="header1">House Harkonnen</h2>
				<img id="banner" src="https://i.imgur.com/miSfIdb.png"></img>
				<h3 id="header2">Fierce, ruthless warriorkin whom are House Atreides' sworn enemies</h3>
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
 		PanelDrawBlur(self, 15)
 		DunePaint_DFrame(w,h)
 	end
end 
function set_class() 
	ClassFrame = vgui.Create("DFrame") 
	ClassFrame:SetPos(0, 0)
	ClassFrame:SetSize( ScrW(), ScrH() )
	ClassFrame:SetTitle("")
	ClassFrame:SetVisible(true) 
	ClassFrame:SetDraggable(false) 
	ClassFrame:ShowCloseButton(false) 
	ClassFrame:MakePopup() 
	InMenu = true
	local html = vgui.Create("DHTML", ClassFrame)
	html:Dock(FILL)

	html:SetHTML([[
		<link rel="preconnect" href="https://fonts.googleapis.com">
		<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
		<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;600;700&display=swap" rel="stylesheet">
		<style>
			html {
				overflow: hidden;
			}
			#title {
				text-align: center;
				color: white;
				font-size: 50px;
				font-family:'Orbitron', sans-serif;
			}
			#header1 {
				font-size: 40px;
				margin-bottom: 5%;
				color: white;
				font-family:'Orbitron', sans-serif;
			}
			#header2 {
				margin-bottom: 5%;
				color: white;
				font-family:'Orbitron', sans-serif;
			}
			#housedescription {
				color: white;
				font-family:'Orbitron', sans-serif;
			}
			#banner {
				width: 30%;
			}
			#line {
				border-top: 3px solid #bbb;
				margin-bottom: -4%;
			}
			#maincontainer{
				display: flex;  
      			flex-direction: row;
			}
			#outer {
				margin: 4%;
				margin-top: 18%;
				float:left;
				width: 17%;
				justify-content: center;
				align-items: center;
				text-align: center;
			}
			#outer2 {
				float:left;
				width: 40%;
				justify-content: center;
				align-items: center;
				text-align: center;
			}
		</style>
		<h1 id="title" style="">Class Selection</h1>
		<div id="line"></div>
		<div id="outer">
			<a onclick='console.log("RUNLUA:D_SetClass(1)")'>
				<h2 id="header1">Assault</h2>
				<img id="banner" src="https://i.imgur.com/EKvp2kh.png"></img>
				<h3 id="header2">You have iron discipline (and a good aim).</h3>
			</a>
		</div>
		<div id="outer">
			<a onclick='console.log("RUNLUA:D_SetClass(2)")'>
				<h2 id="header1">Recon</h2>
				<img id="banner" src="https://i.imgur.com/vcLZfEt.png"></img>
				<h3 id="header2">You prefer silent takeouts and distance.</h3>
			</a>
		</div>
		<div id="outer">
			<a onclick='console.log("RUNLUA:D_SetClass(3)")'>
				<h2 id="header1">Specialist</h2>
				<img id="banner" src="https://i.imgur.com/Crca5Rc.png"></img>
				<h3 id="header2">You are anger incarnate.</h3>
			</a>
		</div>
		<div id="outer">
			<a onclick='console.log("RUNLUA:D_SetClass(4)")'>
				<h2 id="header1">Allied</h2>
				<img id="banner" src="https://i.imgur.com/Aa8sl1F.png"></img>
				<h3 id="header2">Fremen fight for Atreides, Sardaukar for Harkonnen.</h3>
			</a>
		</div>
		<script>
		</script>
	]])

	html:SetAllowLua(true)
	function ClassFrame:OnClose()
		InMenu = false
	end
 	function ClassFrame:Paint(w,h)
 		PanelDrawBlur(self, 15)
 		DunePaint_DFrame(w,h)
 	end
end 

concommand.Add("dune_team", set_team)
concommand.Add("dune_class", set_class)
concommand.Add("dune_credits", credits)

-- Hide HUD
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
end )

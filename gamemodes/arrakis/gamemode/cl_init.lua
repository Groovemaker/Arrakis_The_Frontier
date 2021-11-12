-- Clientside
include("shared.lua")
 
function DunePaint_DFrame(w,h)
	draw.RoundedBox(1, 0, 0, w, h, Color(0,0,0,155))
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
	/*
	TeamFrame_Join1 = vgui.Create("DButton", TeamFrame) 
	TeamFrame_Join1:SetPos(30, 30)
	TeamFrame_Join1:SetSize(100, 50) 
	TeamFrame_Join1:SetText("Atreides") 
	TeamFrame_Join1.DoClick = function()
		D_JAtreides()
	end 
	

	TeamFrame_Join2 = vgui.Create("DButton", TeamFrame) 
	TeamFrame_Join2:SetPos(30, 85) //Place it next to our previous one 
	TeamFrame_Join2:SetSize(100, 50) 
	TeamFrame_Join2:SetText("Harkonnen") 
	TeamFrame_Join2.DoClick = function()
		D_JHarkonnen()
	end 
	*/
 	function TeamFrame:Paint(w,h)
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
		  -webkit-animation: movenames 10s linear infinite;  
		  -moz-animation: movenames 10s linear infinite;  
		  animation: movenames 10s linear infinite;  
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
		@-webkit-keyframes movenames {
			0% {margin-top: 400px;}
			100% {margin-bottom: 150px;}
		}
		@-moz-keyframes movenames {
			0% {margin-top: 400px;}
			100% {margin-bottom: 150px;}
		}
		@-o-keyframes movenames {
			0% {margin-top: 400px;}
			100% {margin-bottom: 150px;}
		}
		keyframes movenames {
			0% {margin-top: 400px;}
			100% {margin-bottom: 150px;}
		}
		</style>
		<div class="container">
    		<div class="credits">
    			<img id="image1" src="https://i.imgur.com/kBVrgZe.png"></img>
	    		<h3>A Game By</h3>
	    		<span>Runic</span>
	    		<h3>Featuring Addons From</h3>
	    		<span>TFA</span>
	    		<h3>Featuring Music and Sounds by</h3>
	    		<span>ash19 - Land of Twists</span>	    		
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
concommand.Add( "dune_team", set_team )
concommand.Add( "dune_credits", credits ) 
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
		  
		  -moz-animation: movenames 45s linear infinite;
		  -webkit-animation: movenames 45s linear infinite;
		  animation: movenames 45s linear infinite;
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
	    		<span>slownls - Blur Tricks
	    		<br />Kefta - Weapon Hud Basics
	    		<br />Fred-Tension - HUD Blur Tricks</span>
	    		<h3>Featuring Music and Sounds by</h3>
	    		<span>ash19 - Land of Twists</span>
	    		<h3>Special thanks to the testers</h3>
	    		<span>
	    		Payback<br />
	    		Gō_Mifune_97<br />
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
	    		<br /><br />
	    		<h2>Frank Herbert <br /> Denis Villeneuve <br /> and Warner Bros. Pictures <br /></h2>
	    		<span>for their outstanding work in the DUNE franchise</span>
	    		<br /><br /><br />
	    		<h1>And YOU, for playing!</h1>
    		</div>
		</div>
	]])

	sound.PlayFile("sound/arrakis_credits.mp3", "noblock", function(station,erid,err)
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
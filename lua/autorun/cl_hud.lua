if not CLIENT then return end
local function DrawBoxBlur( x, y, w, h, layers, density, alpha )
	local blur = Material( "pp/blurscreen" )
	surface.SetDrawColor( 255, 255, 255, alpha ) 
	surface.SetMaterial( blur ) 
	for i = 1, layers do 
		blur:SetFloat( "$blur", ( i / layers ) * density ) 
		blur:Recompute() 
		render.UpdateScreenEffectTexture() 
		render.SetScissorRect( x, y, x + w, y + h, true ) 
		surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() ) 
		render.SetScissorRect( 0, 0, 0, 0, false ) 
	end
end
surface.CreateFont("HP",{
	font = "Helvetica",
	extended = false,
	size = 42,
	weight = 500,
	blursize = 0.5,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("Capturer",{
	font = "Helvetica",
	extended = false,
	size = 26,
	weight = 500,
	blursize = 1.3,
	scanlines = 2,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("Scorer",{
	font = "Helvetica",
	extended = false,
	size = 26,
	weight = 500,
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
})

net.Receive("ScoreManip", function()
	iTeam = net.ReadInt(32)
	iScore = net.ReadInt(32)
	if iTeam == 1 then
		ScoreAtreides = iScore
	elseif iTeam == 2 then
		ScoreHarkonnen = iScore
	end
end)

net.Receive("HarvesterManip", function()
	iTeam = net.ReadInt(32)
	iHarvesters = net.ReadInt(32)
	if iTeam == 1 then
		HarvAtreides = iHarvesters
	elseif iTeam == 2 then
		HarvAtreides = iHarvesters
	end
end)

CaptureMessage = ""

net.Receive("Capture", function()
	iTeam = net.ReadInt(32)
	iHarvester = net.ReadInt(32)
	if iTeam == 1 then
		if(LocalPlayer():Team() == iTeam) then
			CaptureMessage = "We are capturing Harvester ["..iHarvester.."]"
		else
			CaptureMessage = "Enemy is capturing harvester ["..iHarvester.."]"
		end
	elseif iTeam == 2 then
		if(LocalPlayer():Team() == iTeam) then
			CaptureMessage = "We are capturing Harvester ["..iHarvester.."]"
		else
			CaptureMessage = "Enemy is capturing harvester ["..iHarvester.."]"
		end
	end
end)

net.Receive("Decapture", function()
	iTeam = net.ReadInt(32)
	iHarvester = net.ReadInt(32)
	CaptureMessage = ""
end)
print(ScoreAtreides)
hook.Add( "HUDPaint", "Dune_DrawHUD", function()
	if (InMenu == true) then return end
	function GetAmmoForCurrentWeapon( ply )
		if ( !IsValid( ply ) ) then return -1 end

		local wep = ply:GetActiveWeapon()
		if ( !IsValid( wep ) ) then return -1 end
	 	ammostuff = wep:Clip1() * 5.6
		return ammostuff
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

	--Objectives
	--Atreides
	local Mult = 2.5
	local Mult2 = 3.7
	local Mult3 = 4.1
	local Aleph = 111
	DrawBoxBlur(ScrW() / 11 , ScrH() * 0.025, ScrW() / 15, ScrH() / 20,11,4,255)
	draw.RoundedBox( 4, ScrW() / 11 , ScrH() * 0.025, ScrW() / 15, ScrH() / 20, Color(5,5,5,Aleph/1.8) )

	DrawBoxBlur(ScrW() / 6 , ScrH() * 0.04, ScrW() * 5000 / 18000, ScrH() / 55,11,4,255)
	draw.RoundedBox( 4, ScrW() / 6 , ScrH() * 0.04, ScrW() * 5000 / 18000, ScrH() / 55, Color(5,5,5,Aleph/1.8) )
	draw.RoundedBox( 4, ScrW() / 6 , ScrH() * 0.04, ScrW() * ScoreAtreides / 18000, ScrH() / 55, Color( (AtreidesCol.r*Mult), (AtreidesCol.g*Mult), (AtreidesCol.b*Mult), Aleph/1.3 ))

	surface.SetDrawColor(Color( (AtreidesCol.r*Mult3), (AtreidesCol.g*Mult3), (AtreidesCol.b*Mult3), Aleph*1.9 ))
	surface.SetMaterial(Material("materials/atreides.png"))
	surface.DrawTexturedRect(ScrW() * 0.42 , ScrH() * 0.0065, ScrW()/22, ScrH()/14)

	--Harkonnen
	DrawBoxBlur(ScrW() / 1.1953, ScrH() * 0.025, ScrW() / 15, ScrH() / 20,11,4,255)
	draw.RoundedBox( 4, ScrW() / 1.1953, ScrH() * 0.025, ScrW() / 15, ScrH() / 20, Color(5,5,5,Aleph/1.8) )

	DrawBoxBlur(ScrW() * 0.55 , ScrH() * 0.04, ScrW() * 5000 / 18000, ScrH() / 55,11,4,255)
	draw.RoundedBox( 4, ScrW() * 0.55 , ScrH() * 0.04, ScrW() * 5000 / 18000, ScrH() / 55, Color(5,5,5,Aleph/1.8) )
	draw.RoundedBox( 4, ScrW() * 0.55 , ScrH() * 0.04, ScrW() * ScoreHarkonnen / 18000, ScrH() / 55, Color( (HarkonnenCol.r*Mult), (HarkonnenCol.g*Mult), (HarkonnenCol.b*Mult), Aleph/1.3 ))

	surface.SetDrawColor(Color( (HarkonnenCol.r*Mult2), (HarkonnenCol.g*Mult2), (HarkonnenCol.b*Mult2), Aleph*1.9 ))
	surface.SetMaterial(Material("materials/harkonnen.png"))
	surface.DrawTexturedRect(ScrW() * 0.5156, ScrH() * 0.0015, ScrW()/21, ScrH()/12)

	-- Status
	draw.SimpleText(CaptureMessage, "Capturer", ScrW() / 2.03 ,ScrH() *0.12, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	-- Scores
	draw.SimpleText(ScoreAtreides, "Scorer", ScrW() / 7.97 ,ScrH() *0.05, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(ScoreHarkonnen, "Scorer", ScrW() / 1.15 ,ScrH() *0.05, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	--Health Bar
	--draw.RoundedBox( 4, ScrW() / 5.5, ScrH() / (1.1*35), ScrW() / 1.6, ScrH() / 55, Color(1,1,1,100) )
	--draw.RoundedBox( 6, ScrW() / 5.45, ScrH() / (1.025*35), ScrW() * HP / 161, ScrH() / 73.5, Color(255, 255, 255, 100) )	

	--Shield Bar
	--draw.RoundedBox( 6, ScrW() / 5.45, ScrH() / (1.025*35), ScrW() * Armor / 161, ScrH() / 73.5, Color(111, 155, 255, 155) )

	local BGCol = Color(1,1,1,1)
	-- main body
	if LocalPlayer():Team() == 1 then
		BGCol = AtreidesCol
	elseif LocalPlayer():Team() == 2 then
		BGCol = HarkonnenCol
	end

	--Health Bar
	draw.SimpleText("✙"..HP.."", "HP", ScrW() / 16.3 ,ScrH() / 1.10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	
	draw.RoundedBox( 4, ScrW() / 16.08 , ScrH() / 1.07, ScrW() * 100 / 709, ScrH() / 77, Color(130, 100, 0, 105) )
	draw.RoundedBox( 4, ScrW() / 16.08 , ScrH() / 1.07, ScrW() * HP / 709, ScrH() / 77, Color(200, 1, 1, 155) )

	--Armor Bar
	draw.RoundedBox( 0, ScrW() / 16.08 , ScrH() / 1.058, ScrW() * 100 / 709, ScrH() / 260, Color(130, 100, 0, 105) )
	draw.RoundedBox( 0, ScrW() / 16.08 , ScrH() / 1.058, ScrW() * Armor / 709, ScrH() / 260, Color(255, 255, 255, 155) )
	
	--Ammo Bar
	draw.RoundedBox( 0, ScrW() / 16.08 , ScrH() / 1.05, ScrW() * 100 / 709, ScrH() / 260, Color(0, 100, 30, 105) )
	draw.RoundedBox( 0, ScrW() / 16.08 , ScrH() / 1.05, ScrW() * Ammo / 709, ScrH() / 260, Color(0, 255, 100, 155) )

	DrawBoxBlur(ScrW() / 60.08, ScrH() *0.89, ScrW() / 25, ScrH() / 15 ,11,4,255)
	draw.RoundedBox( 0, ScrW() / 60.08, ScrH() *0.89, ScrW() / 25, ScrH() / 15 , BGCol)

	if Abilities.GrenadeCoolBar == 0 then
		surface.SetDrawColor(Color(111,111,111,200))
	elseif Abilities.GrenadeCoolBar == 1 then
		surface.SetDrawColor(Color(200,200,200,200))
	end

	if Abilities.GrenadeCoolBar == 0 then
		Abilities.GrenadeDidSound = 0
	elseif Abilities.GrenadeCoolBar == 1 && Abilities.GrenadeDidSound == 0 then
		surface.PlaySound("grenade_recharged.wav")
		Abilities.GrenadeDidSound = 1
	end

	surface.SetMaterial(Material("materials/ability_grenade.png"))
	surface.DrawTexturedRect(ScrW() / 40, ScrH() *0.9, ScrW()/44, ScrH()/23)
	
end )


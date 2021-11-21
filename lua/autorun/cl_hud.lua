if not CLIENT then return end

-- Vars
HarvesterClaims = {0,0,0}
CaptureMessage = ""
RoundEnd = false
AlliedReady = 0

-- Fonts
surface.CreateFont("HP",{
	font = "Orbitron",
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
	font = "Trebuchet24",
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

surface.CreateFont("Allied",{
	font = "Trebuchet24",
	extended = false,
	size = 37,
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
	font = "Orbitron",
	extended = false,
	size = 26,
	weight = 500,
	blursize = 1.1,
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

surface.CreateFont("HarvesterID",{
	font = "Trebuchet24",
	extended = false,
	size = 26,
	weight = 500,
	blursize = 1.1,
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

surface.CreateFont("Harvesters",{
	font = "Trebuchet24",
	extended = false,
	size = 32,
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

surface.CreateFont("END1",{
	font = "Trebuchet24",
	extended = false,
	size = 42,
	weight = 400,
	blursize = 1.2,
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

surface.CreateFont("END2",{
	font = "Trebuchet24",
	extended = false,
	size = 32,
	weight = 100,
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

surface.CreateFont("NametagsFont",{
	font = "Orbitron",
	extended = false,
	size = 21,
	weight = 500,
	blursize = 1.1,
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

surface.CreateFont("END3",{
	font = "Orbitron",
	extended = false,
	size = 42,
	weight = 400,
	blursize = 1.2,
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

-- Blur
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
	local iTeam = net.ReadInt(32)
	local iHarvester = net.ReadInt(32)
	HarvesterClaims[iHarvester] = iTeam
	--print("Harvester: "..iHarvester.." -- ".."Team: "..iTeam)
end)



net.Receive("Capture", function()
	local iTeam = net.ReadInt(32)
	local iHarvester = net.ReadInt(32)
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
	local iTeam = net.ReadInt(32)
	local iHarvester = net.ReadInt(32)
	CaptureMessage = ""
end)



-- Thx to gmod-o-poly for basic understanding!
function NameTag()

	-- Player
	for k, v in pairs(player.GetAll()) do
	teamcolor = team.GetColor(v:Team())
		if v:Alive() && v:Team() == LocalPlayer():Team() then
		    if v:Nick() != LocalPlayer():Nick() then
		    	if v:InVehicle() then
		    		DIST = 999999999999
		    	else
		    		DIST = 2000
		    	end
				if LocalPlayer():GetPos():Distance(v:GetPos()) <= DIST then
					pos = v:GetPos()
					pos.z = pos.z + 70
					pos = pos:ToScreen()
					if v:Team() == 1 then
						surface.SetMaterial(Material("materials/atreides.png"))
						surface.SetDrawColor(team.GetColor(v:Team()))
						surface.DrawTexturedRect( pos.x-15, pos.y - 75, 32, 32 )	
					end						
					if v:Team() == 2 then
						surface.SetMaterial(Material("materials/harkonnen.png"))
						surface.SetDrawColor(team.GetColor(v:Team()))
						surface.DrawTexturedRect( pos.x-15, pos.y - 75, 25, 32 )	
					end
					draw.DrawText(v:Name(), "NametagsFont", pos.x, pos.y -38, team.GetColor(v:Team()), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		end
	end

	-- Harvester Location
	for k, v in pairs(ents.FindByClass("prop_thumper")) do
		if LocalPlayer():GetPos():Distance(v:GetPos()) >= 2000 then
			pos = v:GetPos()
			pos.z = pos.z + 70
			pos = pos:ToScreen()
			local HarvCol = Color(0,0,0,0)
			if HarvesterClaims[k] == 0 then
				HarvCol = Color(255,255,255,155)
			else
				HarvCol = team.GetColor(HarvesterClaims[k])
			end
			draw.DrawText("["..v:GetNWInt("harvester_id").."]", "HarvesterID", pos.x, pos.y -38, HarvCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

end

hook.Add("HUDPaint", "Dune_DrawHUD", function()
	if InMenu then return end
	if RoundEnd == true then 
		local Mult = 2.5
		local Mult2 = 3.7
		local Mult3 = 4.1
		local Aleph = 166
		DrawBoxBlur(ScrW()*0.05, ScrH()*0.05, ScrW()*0.9, ScrH()*0.85,11,4,255)
		draw.RoundedBox( 6, ScrW()*0.05, ScrH()*0.05, ScrW()*0.9, ScrH()*0.85, Color(35,35,35,Aleph/1.8) )
		draw.RoundedBox( 8, ScrW()*0.35, ScrH()*0.176, ScrW()*0.2835, ScrH()*0.15, Color(35,35,35,Aleph/1.9) )

		surface.SetDrawColor(Color( 255,255,255, Aleph*1.9 ))
		draw.SimpleText("The Battle has Concluded!", "END1", ScrW() / 2.04 ,ScrH() *0.25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(Color( 255,255,255, Aleph/1.3 ))
		surface.SetMaterial(Material("materials/atreides.png"))
		surface.DrawTexturedRect(ScrW() * 0.375 , ScrH() * 0.45, (ScrH()/12), (ScrH()/12))

		surface.SetDrawColor(Color( 255,255,255, Aleph/1.3 ))
		surface.SetMaterial(Material("materials/harkonnen.png"))
		surface.DrawTexturedRect(ScrW() * 0.555 , ScrH() * 0.443, (ScrH()/12), (ScrH()/10))

		draw.SimpleText(ScoreAtreides, "END3", ScrW() * 0.399 , ScrH() * 0.60, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(ScoreHarkonnen, "END3", ScrW() * 0.5785 , ScrH() * 0.60, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		return 
	end

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
	local Aleph = 99
	DrawBoxBlur(ScrW() / 11 , ScrH() * 0.025, ScrW() / 15, ScrH() / 20,11,4,255)
	draw.RoundedBox( 4, ScrW() / 11 , ScrH() * 0.025, ScrW() / 15, ScrH() / 20, Color(5,5,5,Aleph/1.8) )

	DrawBoxBlur(ScrW() / 6 , ScrH() * 0.04, ScrW() * 5000 / 18000, ScrH() / 55,11,4,255)
	draw.RoundedBox( 4, ScrW() / 6 , ScrH() * 0.04, ScrW() * 5000 / 18000, ScrH() / 55, Color(5,5,5,Aleph/1.8) )
	draw.RoundedBox( 4, ScrW() / 6 , ScrH() * 0.04, ScrW() * ScoreAtreides / 18000, ScrH() / 55, Color( (AtreidesCol.r*Mult), (AtreidesCol.g*Mult), (AtreidesCol.b*Mult), Aleph/1.3 ))

	surface.SetDrawColor(Color( (AtreidesCol.r*Mult3), (AtreidesCol.g*Mult3), (AtreidesCol.b*Mult3), Aleph*1.9 ))
	surface.SetMaterial(Material("materials/atreides.png"))
	surface.DrawTexturedRect(ScrW() * 0.42 , ScrH() * 0.0065, ScrW()/22, ScrH()/14)

	--Harkonnen
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

	-- Allied Status
	local flashAlpha = math.Clamp(math.sin(CurTime() * 11) * 255, 0, 255)
	if AlliedReady == 1 then
		draw.SimpleText("Allied Class READY!", "Allied", ScrW() / 1.2 ,ScrH() *0.90, Color(255,255,255, flashAlpha, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER))
	end
	local BGCol = Color(1,1,1,1)

	if LocalPlayer():Team() == 1 then
		BGCol = AtreidesCol
		surface.SetDrawColor(Color( 111,255,200, 105 ))
		surface.SetMaterial(Material("materials/atreides.png"))
		surface.DrawTexturedRect(ScrW() * 0.215 , ScrH() * 0.91, (ScrH()/17), (ScrH()/19))
	elseif LocalPlayer():Team() == 2 then
		BGCol = HarkonnenCol
		surface.SetDrawColor(Color( 255,11,11, 155 ))
		surface.SetMaterial(Material("materials/harkonnen.png"))
		surface.DrawTexturedRect(ScrW() * 0.215 , ScrH() * 0.91, (ScrH()/19), (ScrH()/19))
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

	-- Claims Atreides
	DrawBoxBlur(ScrW() / 11 , ScrH() * 0.095, ScrW() / 15, ScrH() / 25, 11,4,255)
	draw.RoundedBox( 4, ScrW() / 11 , ScrH() * 0.095, ScrW() / 15, ScrH() / 25, Color(5,5,5,Aleph/1.8) )

	if HarvesterClaims[1] == 1 then
		draw.SimpleText("1", "Harvesters", ScrW() / 10 ,ScrH() * 0.1125, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("1", "Harvesters", ScrW() / 10 ,ScrH() * 0.1125, Color(144,144,144,111), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if HarvesterClaims[2] == 1 then
		draw.SimpleText("2", "Harvesters", ScrW() / 8 ,ScrH() * 0.1125, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("2", "Harvesters", ScrW() / 8 ,ScrH() * 0.1125, Color(144,144,144,111), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if HarvesterClaims[3] == 1 then
		draw.SimpleText("3", "Harvesters", ScrW() / 6.8 ,ScrH() * 0.1125, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("3", "Harvesters", ScrW() / 6.8 ,ScrH() * 0.1125, Color(144,144,144,111), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	 	
	-- Claims Harkonnen
	DrawBoxBlur(ScrW() / 1.1953 , ScrH() * 0.095, ScrW() / 15, ScrH() / 25, 11,4,255)
	draw.RoundedBox( 4, ScrW() / 1.1953, ScrH() * 0.095, ScrW() / 15, ScrH() / 25, Color(5,5,5,Aleph/1.8) )

	if HarvesterClaims[1] == 2 then
		draw.SimpleText("1", "Harvesters", ScrW() * 0.8445 ,ScrH() * 0.1125, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("1", "Harvesters", ScrW() * 0.8445 ,ScrH() * 0.1125, Color(144,144,144,111), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if HarvesterClaims[2] == 2 then
		draw.SimpleText("2", "Harvesters", ScrW() / 1.15 ,ScrH() * 0.1125, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("2", "Harvesters", ScrW() / 1.15 ,ScrH() * 0.1125, Color(144,144,144,111), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if HarvesterClaims[3] == 2 then
		draw.SimpleText("3", "Harvesters", ScrW() * 0.8925 ,ScrH() * 0.1125, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("3", "Harvesters", ScrW() * 0.8925 ,ScrH() * 0.1125, Color(144,144,144,111), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

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
end)




hook.Add("PreDrawHalos", "L4DGlow", function()
	for k,v in pairs(player.GetAll()) do
		if v:Alive() == true && v:Health() ~= 0 && v:Health() >= 0 && LocalPlayer():Alive() && v:Team() == LocalPlayer():Team() && v != LocalPlayer() && !v:InVehicle() then
			halo.Add( {v},  team.GetColor(v:Team()), 1, 1, 5, true, true )
		elseif v:Alive() == true && v:Health() ~= 0 && v:Health() >= 0 && LocalPlayer():Alive() && v:Team() == LocalPlayer():Team() && v != LocalPlayer() && v:InVehicle() then
			--halo.Add( {v:GetVehicle()},  team.GetColor(v:Team()), 1, 1, 5, true, true )
		end
	end
end)


hook.Add("HUDPaint", "NameTags", NameTag)

function WinRound(iTeam)
	RoundEnd = true
	WinningTeam = iTeam
end


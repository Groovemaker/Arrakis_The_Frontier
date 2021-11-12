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
	size = 55,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})

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



	--Health Bar
	draw.RoundedBox( 4, ScrW() / 5.5, ScrH() / (1.1*35), ScrW() / 1.6, ScrH() / 55, Color(1,1,1,100) )
	draw.RoundedBox( 6, ScrW() / 5.45, ScrH() / (1.025*35), ScrW() * HP / 161, ScrH() / 73.5, Color(255, 255, 255, 100) )	

	--Shield Bar
	draw.RoundedBox( 6, ScrW() / 5.45, ScrH() / (1.025*35), ScrW() * Armor / 161, ScrH() / 73.5, Color(111, 155, 255, 155) )

	local BGCol = Color(1,1,1,1)
	-- main body
	if LocalPlayer():Team() == 1 then
		BGCol = AtreidesCol
	elseif LocalPlayer():Team() == 2 then
		BGCol = HarkonnenCol
	end
	draw.RoundedBox( 4, ScrW() / 16.08 , ScrH() / 1.07, ScrW() * 100 / 709, ScrH() / 77, Color(130, 100, 0, 105) )
	draw.RoundedBox( 4, ScrW() / 16.08 , ScrH() / 1.07, ScrW() * HP / 709, ScrH() / 77, Color(200, 1, 1, 155) )

	draw.RoundedBox( 0, ScrW() / 16.08 , ScrH() / 1.058, ScrW() * 100 / 709, ScrH() / 260, Color(130, 100, 0, 105) )
	draw.RoundedBox( 0, ScrW() / 16.08 , ScrH() / 1.058, ScrW() * Armor / 709, ScrH() / 260, Color(255, 255, 255, 155) )

	draw.RoundedBox( 0, ScrW() / 16.08 , ScrH() / 1.05, ScrW() * 100 / 709, ScrH() / 260, Color(0, 100, 30, 105) )
	draw.RoundedBox( 0, ScrW() / 16.08 , ScrH() / 1.05, ScrW() * Ammo / 709, ScrH() / 260, Color(0, 255, 100, 155) )

	DrawBoxBlur(ScrW() / 60.08, ScrH() *0.89, ScrW() / 25, ScrH() / 15 ,11,4,255)
	draw.RoundedBox( 0, ScrW() / 60.08, ScrH() *0.89, ScrW() / 25, ScrH() / 15 , BGCol)
	surface.SetDrawColor(Color(155,155,155,255))
	surface.SetMaterial(Material("materials/ability_grenade.png"))
	surface.DrawTexturedRect(ScrW() / 40, ScrH() *0.9, ScrW()/44, ScrH()/23)
	
end )
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


	-- main body
	/*
	draw.RoundedBox( 2, ScrW() / 60.08, ScrH() / 21, ScrW() / 4.6, ScrH() / 19 , Color(30,30,30,155) )

	draw.RoundedBox( 0, ScrW() / 19.08 , ScrH() / 13, ScrW() * 100 / 709, ScrH() / 260, Color(130, 100, 0, 105) )
	draw.RoundedBox( 0, ScrW() / 19.08 , ScrH() / 13, ScrW() * HP / 709, ScrH() / 260, Color(255, 200, 0, 155) )

	draw.RoundedBox( 0, ScrW() / 19.08 , ScrH() / 11.8, ScrW() * 100 / 709, ScrH() / 260, Color(0, 100, 30, 105) )
	draw.RoundedBox( 0, ScrW() / 19.08 , ScrH() / 11.8, ScrW() * Ammo / 709, ScrH() / 260, Color(0, 255, 100, 155) )
	*/
end )
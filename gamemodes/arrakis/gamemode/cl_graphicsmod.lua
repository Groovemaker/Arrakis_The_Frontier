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
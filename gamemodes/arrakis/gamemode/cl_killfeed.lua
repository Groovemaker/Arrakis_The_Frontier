local hud_deathnotice_time = CreateConVar( "hud_deathnotice_time", "6", FCVAR_REPLICATED )
local Deaths = {}



surface.CreateFont("Killfeed1",{
	font = "ChatFont",
	extended = false,
	size = 20,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})

local Deaths = {}
local SuicideFunnies = {
	"tried eating sand.",
	"wiped their ass with spice.",
	"thought he was a VTOL.",
	"didn't have the high ground.",
	"was unborn.",
	"thought he was in godmode."
}
net.Receive("PlyKill", function()
	local Tbl = {}
	Tbl.Victim = net.ReadEntity()
	Tbl.Player = net.ReadEntity()
	Tbl.Text = "killed"
	Tbl.Time = CurTime()
	Tbl.Suicide = 0
	
	if Tbl.Victim == Tbl.Player then
		Tbl.Suicide = 1
		Tbl.Text = SuicideFunnies[math.random(#SuicideFunnies)]
	end

	table.insert( Deaths, Tbl )
end)


function GM:DrawDeathNotice( x, y )
	local hud_deathnotice_time = hud_deathnotice_time:GetFloat()
	
	x = ScrW() / 12
	--y = y * ScrH()
	y = ScrH()*0.3
	
	for k, Death in pairs( Deaths ) do
		if ( Death.Time + hud_deathnotice_time > CurTime() ) then
			if ( Death.lerp ) then
				--x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
			end
			
			Death.lerp = Death.lerp or {}
			Death.lerp.x = x
			Death.lerp.y = y
			
			surface.SetFont( "Killfeed1" )
			Death.w, Death.h = surface.GetTextSize( Death.Text )
			
			local fadeout = ( Death.Time + hud_deathnotice_time ) - CurTime()
			
			local alpha = math.Clamp( fadeout * 255, 0, 255 )
			
			local ACol = team.GetColor(Death.Player:Team())
			local TCol = team.GetColor(Death.Victim:Team())
			ACol.a = alpha
			TCol.a = alpha
			
			if Death.Suicide == 0 then
				draw.SimpleText(Death.Player:Nick(), "Killfeed1", x - 61, y, ACol, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				draw.SimpleText(Death.Text, "Killfeed1", (x - 60) + (surface.GetTextSize(Death.Player:Nick())*1.07), y, Color( 255, 255, 255, alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				draw.SimpleText(Death.Victim:Nick(), "Killfeed1", (x - 60) + ((surface.GetTextSize(Death.Text)+surface.GetTextSize(Death.Player:Nick()))*1.1), y, TCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			else
				draw.SimpleText(Death.Player:Nick(), "Killfeed1", x - 61, y, ACol, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				draw.SimpleText(Death.Text, "Killfeed1", (x - 60) + (surface.GetTextSize(Death.Player:Nick())*1.07), y, Color( 255, 255, 255, alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
			end
		
			y = y + Death.h * 1.25
		end
	end
	
	for k, Death in pairs( Deaths ) do
		if ( Death.Time + hud_deathnotice_time > CurTime() ) then
			return
		end
	end
	
	Deaths = {}
end
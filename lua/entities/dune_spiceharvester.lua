AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Type = "anim"
ENT.PrintName		= "Spice Harvester"
ENT.Author			= "Runic"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SpawnFunction( ply, tr, ClassName )

	local ent = ents.Create( ClassName )
	ent:SetRenderMode( RENDERMODE_TRANSALPHA )
	ent:SetColor(Color(255,255,255,0))
	ent:SetAngles(Angle(0,-120,0))
	ent:Spawn()
	--ent:Activate()
	ent:SetSolid(1)

	return ent
end

if SERVER then
	function ENT:GetHarvester()
		return self.Thumper
	end
end

function ENT:Initialize()
	self:PhysicsInitBox(Vector(10,10,1),Vector(-10,-10,50))
	if SERVER then
		Thumper[self:EntIndex()] = ents.Create("prop_thumper")
		Thumper[self:EntIndex()]:SetRenderMode(RENDERMODE_TRANSALPHA)
		Thumper[self:EntIndex()]:SetColor(Color(255,255,255,255))
		Thumper[self:EntIndex()]:SetAngles(Angle(0,-120,0))
		Thumper[self:EntIndex()]:Spawn()
		Thumper[self:EntIndex()]:SetPos(self:GetPos())
		Thumper[self:EntIndex()]:Fire("Enable")
		Thumper[self:EntIndex()]:SetSolid(1)
	end
end

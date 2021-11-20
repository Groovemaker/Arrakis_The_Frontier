Abilities = {}
Abilities.GrenadeClassname = "weapon_frag"


--------------------------------
-- Grenade
------------------------------

-- Client

if CLIENT then
	function Abilities.Grenade(ply)
		ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE, true)
	end
end

-- Server
if SERVER then
	function Abilities.Grenade(ply)
		if ply.CanGrenade == true then
			local aimvec = ply:GetAimVector()
			local pos = aimvec * 1116
			local GrenadeA = ents.Create("npc_grenade_frag")
			local att = ply:GetAttachment(ply:LookupAttachment("anim_attachment_rh"))
			GrenadeA:SetPos(att.Pos)
			GrenadeA:Fire("settimer", "2")
			GrenadeA:SetAngles(ply:EyeAngles())
			pos:Add(ply:EyePos())
		 	GrenadeA:Spawn()
		 	GrenadeA:SetPhysicsAttacker(ply)
		 	GrenadeA:SetOwner(ply)
		 	ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE, true)
			local phys = GrenadeA:GetPhysicsObject()
			if (not phys:IsValid()) then GrenadeA:Remove() return end
			aimvec:Mul(1001) -- Force of throw
			aimvec:Add(VectorRand(-10, 10))
			phys:ApplyForceCenter(aimvec)
			BroadcastLua([[Abilities.Grenade(Player(]]..ply:UserID()..[[))]])
			ply:SendLua([[Abilities.GrenadeCoolBar = 0]])
			ply.CanGrenade = false
			timer.Simple(CVAR_GrenadeCooldown:GetFloat(), function()
				if !IsValid(ply) then return end
				ply.CanGrenade = true 
				ply:SendLua([[Abilities.GrenadeCoolBar = 1]])
			end)
		end
	end
end

-- Grenade Damage Modifier
hook.Add("EntityTakeDamage", "Dune_Grenadedamage", function(target, dmginfo)
	if target:IsPlayer() && dmginfo:GetAttacker():GetClass() == "npc_grenade_frag" then
		local GrenadeA = dmginfo:GetAttacker()
		dmginfo:SetAttacker(GrenadeA:GetOwner())
	end
end )

-------------------------------------------------------

-- Shared
hook.Add("PlayerButtonDown", "Dune_Ability_Grenade", function(ply, button)
	if CLIENT then
		if input.GetKeyName(button) == "f" then
			
		end
	else
		if button == 16 && !ply:InVehicle() then
			Abilities.Grenade(ply)
		end
	end
end)


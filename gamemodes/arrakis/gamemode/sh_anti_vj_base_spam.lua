-- This script removes the unneccessary, hellish google scam and nag messages by vj base addons.
-- I dislike the way vj almost adds DRM to his stuff and thus created this to finally shut the crying addons up.
-- Use in any way you like.
-- Regards, Runic.

timer.Remove("VJBASEMissing") -- Cry about it, VJ
VJF = "lolno" -- Cry about it, VJ
OldFileExists = file.Exists -- Cry about it, VJ
function file.Exists(sName, sGamePath) -- Cry about it, VJ
	if sName == "autorun/vj_base_autorun.lua" || sName == "lua/autorun/vj_base_autorun.lua" then -- Cry about it, VJ
		return true -- Cry about it, VJ
	else -- Cry about it, VJ
		OldFileExists(sName, sGamePath) -- Cry about it, VJ
	end -- Cry about it, VJ
end -- Cry about it, VJ
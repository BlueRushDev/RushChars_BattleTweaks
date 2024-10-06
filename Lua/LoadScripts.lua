
if (VERSION == 202) and (SUBVERSION < 10)
	local function piratedversion(v)
		v.fadeScreen(0xFA00, 15)
		v.drawString(200, 30, ("this mod requires SRB2"),V_ORANGEMAP, "center")
		v.drawString(200, 40, ("version 2.2.10 or higher"),V_ORANGEMAP, "center")
		v.drawString(200, 50, ("please update your game"),V_ORANGEMAP, "center")
		local marine = v.cachePatch("PIRACC")
		v.drawScaled(0, 75<<FRACBITS, FRACUNIT/5, marine)
	end
	hud.add(piratedversion, "title")
	hud.add(piratedversion, "game")
	error("Your copy of 2.2 is obsolete and not compatible with this mod. Please update to version 2.2.10 or higher.", 0)
end

local structure = {
	{
		folder = "1 - Everything else",
		scripts = {
			"LUA_IO",
			"LUA_NEWSTUFF.txt",
			"LUA_BLAZECOLORS.txt",
			"LUA_SOLSTUFF.txt",
			"LUA_BOOSTTRAIL.txt",
			"LUA_OLDSHIT.txt",
			"LUA_MARI.txt",
			"LUA_BOAT.txt",
			"Blaze_MoveTail.lua",
			"WindMomentum.lua"
		}
	},
	{
		folder = "2 - Blaze Battle",
		scripts = {
			"1_Defs.lua",
			"2_Hooks.lua"
		}
	}
}

for _, entry in ipairs(structure)
	local folder = entry.folder
	for _, script in ipairs(entry.scripts)
		dofile(folder .. "/" .. script)
	end
end

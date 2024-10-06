// by Lach
// teleports the tail followmobj to be in front of Blaze's sprite for A5/A4A6 views, behind for all others
// of course, because the camera moves after all mobj logic, there will sometimes be 1 frame of delay where it is layered incorrectly :(
// (also Frostiikin is RUDE, followmobjs are absolute darlings and I will love and protect them)

local TAIL_DIST = -3*FRACUNIT

local invertsLUT = { // fill out an entry here to invert whether the tail displays in front or behind Blaze
	{ // WALKA4
		sprite2 = SPR2_WALK,
		frame = A,
		rotation = 4
	},
	{ // WALKF4
		sprite2 = SPR2_WALK,
		frame = F,
		rotation = 4
	},
	{ // WALKG4
		sprite2 = SPR2_WALK,
		frame = G,
		rotation = 4
	},
	{ // WALKH4
		sprite2 = SPR2_WALK,
		frame = H,
		rotation = 4
	},
	{ // WALKE6
		sprite2 = SPR2_WALK,
		frame = E,
		rotation = 6
	},
	{ // WALKB6
		sprite2 = SPR2_WALK,
		frame = B,
		rotation = 6
	},
	{ // WALKC6
		sprite2 = SPR2_WALK,
		frame = C,
		rotation = 6
	},
	{ // WALKD6
		sprite2 = SPR2_WALK,
		frame = D,
		rotation = 6
	},
	{ // RUN_C4
		sprite2 = SPR2_RUN,
		frame = C,
		rotation = 4
	},
	{ // RUN_D4
		sprite2 = SPR2_RUN,
		frame = D,
		rotation = 4
	},
	{ // RUN_A6
		sprite2 = SPR2_RUN,
		frame = A,
		rotation = 6
	},
	{ // RUN_B6
		sprite2 = SPR2_RUN,
		frame = B,
		rotation = 6
	},
	{ // RIDEA4
		sprite2 = SPR2_RIDE,
		frame = A,
		rotation = 4
	},
	{ // RIDEA6
		sprite2 = SPR2_RIDE,
		frame = A,
		rotation = 6
	}
}

local function MakeBitfield(sprite2, frame, rotation)
	return (sprite2) | (frame << 8) | (rotation << 16)
end

// convert the inverts table into an actual look-up table
invertsLUT = (function()
	local result = {}
	for i, entry in ipairs(invertsLUT)
		result[MakeBitfield(entry.sprite2, entry.frame, entry.rotation)] = true
	end
	return result
end)()

// the main tail mover! called from somewhere in Frostiikin's script
rawset(_G, "Blaze_MoveTail", function(player, tail)
	local mo = player.mo
	local scale = mo.scale
	local dist = FixedMul(TAIL_DIST, scale)
	local playerAngle = player.drawangle
	local z = mo.z
	
	tail.angle = playerAngle
	
	// reverse gravity
	if mo.eflags & MFE_VERTICALFLIP
		z = $ + mo.height - tail.height
	end
	
	// sprite offsets
	local sprite2 = mo.sprite2 & ~FF_SPR2SUPER
	local frame = mo.frame & FF_FRAMEMASK
	local unit = scale * P_MobjFlip(mo)
	if sprite2 == SPR2_WALK
		if frame & 1
			z = $ + 2*unit
		elseif (frame/2) & 1
			z = $ + 3*unit
		end
	elseif sprite2 == SPR2_RUN
		if mo.sprite2 & FF_SPR2SUPER
			z = $ - 8*unit
		elseif not (frame & 1)
			z = $ - unit
		end
	elseif sprite2 == SPR2_RIDE
		z = $ - 2*unit
	elseif sprite2 == SPR2_EDGE
		z = $ - 3*unit
	elseif sprite2 == SPR2_SKID
		z = $ - unit
		if not (frame & 1)
			z = $ - unit
		end
	end
	
	if splitscreen // we unfortunately can't pick which camera to use for R_PointToAngle, so just teleport the mobj like normal
	or not camera // doubles as a failsafe in case hud is turned off?
		P_TeleportMove(tail,
			mo.x + P_ReturnThrustX(mo, playerAngle, dist),
			mo.y + P_ReturnThrustY(mo, playerAngle, dist), z)
		return
	end
	
	local flipped = mo.frame & FF_HORIZONTALFLIP or mo.renderflags & RF_HORIZONTALFLIP // we don't care about mo.mirrored since that doesn't affect the direction the sprite faces
	local x = P_ReturnThrustX(mo, camera.angle, scale)
	local y = P_ReturnThrustY(mo, camera.angle, scale)
	local cameraToPlayerAngle = R_PointToAngle2(camera.x + camera.momx, camera.y + camera.momy, mo.x, mo.y)
	local rotation = ((cameraToPlayerAngle - playerAngle + ANGLE_202h) >> 29) + 1 // this gives us the frame rotation number for an 8-angle frame, as written in source 
	local invert = invertsLUT[MakeBitfield(sprite2, mo.frame & FF_FRAMEMASK, rotation)]
	if sprite2 == SPR2_RUN and mo.sprite2 & FF_SPR2SUPER then invert = false end
	
	// A4/A5/A6, tail is closer to camera than player
	if (rotation >= 4 and rotation <= 6) == (not invert)
		x = -$
		y = -$
	end
	
	dist = FixedMul($, cos(camera.angle - playerAngle + ANGLE_90))
	
	if flipped
		dist = -$
	end
	
	x = $ + mo.x + P_ReturnThrustX(mo, camera.angle + ANGLE_90, dist)
	y = $ + mo.y + P_ReturnThrustY(mo, camera.angle + ANGLE_90, dist)
	
	P_TeleportMove(tail, x, y, z)
end)
if GetWindMomentum
	return
end

local PUSH_FACTOR = 9 // why pushers don't just use the actual linedef lengths baffles me
local PUSH_UNIT = (1 << PUSH_FACTOR) // shifting in Lua is not the same as shifting in C, so let's use division against this PUSH_UNIT value instead

local windVec = {x = 0, y = 0, z = 0}

// returns the top and bottom heights of @fof at the @x and @y coordinates specified
local function GetFOFHeightsAt(fof, x, y)
	local top
	local bottom
	
	if fof.t_slope
		top = P_GetZAt(fof.t_slope, x, y)
	else
		top = fof.topheight
	end
	
	if fof.b_slope
		bottom = P_GetZAt(fof.b_slope, x, y)
	else
		bottom = fof.bottomheight
	end
	
	return top, bottom
end

// similar to P_PlayerTouchingSectorSpecial but for mobjs
// unlike P_PlayerTouchingSectorSpecial, does not care about the distinction between touching the floor/ceiling and being inside
// it also only checks the mobj's sector rather than every sector the mobj borders
local function MobjInSectorSpecial(mo, section, number)
	local sector = mo.subsector.sector
	
	if GetSecSpecial(sector.special, section) == number
		return sector
	end
	
	for fof in sector.ffloors()
		sector = fof.sector
		if GetSecSpecial(sector.special, section) ~= number
		or not (fof.flags & FF_EXISTS)
			continue
		end
		
		local top, bottom = GetFOFHeightsAt(fof, mo.x, mo.y)
		
		if mo.z > top
		or mo.z + mo.height < bottom
			continue
		end
		
		return sector
	end
end

// runs a function for every line found with the specified linedef special and tag
local function RunForSpecialLinesFromTag(special, tag, func, ...)
	local i = P_FindSpecialLineFromTag(special, tag)
	
	while i ~= -1
		func(lines[i], ...)
		i = P_FindSpecialLineFromTag(special, tag, i)
	end
end	

local function AddHorizontalMomentum(line)
	windVec.x = $ + (line.dx / PUSH_UNIT)
	windVec.y = $ + (line.dy / PUSH_UNIT)
end

local function AddUpwardsMomentum(line)
	windVec.z = $ + (P_AproxDistance(line.dx, line.dy) / PUSH_UNIT)
end

local function AddDownwardsMomentum(line)
	windVec.z = $ - (P_AproxDistance(line.dx, line.dy) / PUSH_UNIT)
end

// if @mo is in a sector or fof affected by a wind/current, returns the x, y, and z components of the wind/current in that sector or fof
local function GetWindMomentum(mo)
	local sector = MobjInSectorSpecial(mo, 3, 2)
	
	if not sector
		return
	end
	
	local tag = sector.tag
	
	windVec.x, windVec.y, windVec.z = 0, 0, 0
	
	RunForSpecialLinesFromTag(541, tag, AddHorizontalMomentum)
	RunForSpecialLinesFromTag(542, tag, AddUpwardsMomentum)
	RunForSpecialLinesFromTag(543, tag, AddDownwardsMomentum)
	RunForSpecialLinesFromTag(544, tag, AddHorizontalMomentum)
	RunForSpecialLinesFromTag(545, tag, AddUpwardsMomentum)
	RunForSpecialLinesFromTag(546, tag, AddDownwardsMomentum)
	
	return windVec.x, windVec.y, windVec.z
end

// if @mo is in a sector or fof affected by a wind/current, adds the momentum of the wind/current in that sector or fof to the momentum of @mo
local function ApplyWindMomentum(mo)
	local x, y, z = GetWindMomentum(mo)
	if x ~= nil
		mo.momx = $ + x
		mo.momy = $ + y
		mo.momz = $ + z
	end
end

rawset(_G, "GetWindMomentum", GetWindMomentum)
rawset(_G, "ApplyWindMomentum", ApplyWindMomentum)
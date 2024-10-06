local battle_loaded = false
local cooldown_pillar = TICRATE * 4
local cooldown_dive = TICRATE * 3
local cooldown_interrupt = TICRATE
local spread = ANGLE_22h
local pillarthrust = 20*FRACUNIT
local spawntime = TICRATE*2
local pillarduration = TICRATE
local divedownwardspeed = 15
local diveminchargetime = 15
local divemaxchargetime = TICRATE/2
local divespeedmultiplier = 3*FRACUNIT


//local resetboost = function(p)
//	p.blazeboosting = 0
//	p.blazeburstcharge = 0
//end	
		
addHook("MobjSpawn", function(mo)
	mo.flags2 = $ | MF2_SPLAT
end, MT_PYROSPAWNER)

local dopillar = function(mo)
	local pillar = P_SpawnMobjFromMobj(mo, 0, 0, P_MobjFlip(mo) * FRACUNIT, MT_PYROGEYSER)
	
	pillar.target = mo.target
	pillar.color = mo.color
	pillar.hit_sound = sfx_s3k70
	
	if P_RandomKey(2)
		pillar.renderflags = $ | RF_HORIZONTALFLIP
	end
	
	S_StartSoundAtVolume(pillar, sfx_s3k4e, 120)
	S_StartSound(pillar, sfx_blzgsr)
	
	S_StopSoundByID(mo, sfx_s3kc2l)
	P_KillMobj(mo, nil, nil)
end
local dopillars = function(player)
	for i = 1, 4
		if player.blazepillars[i] and player.blazepillars[i].valid
			dopillar(player.blazepillars[i])
		end
	end
end

addHook("MobjThinker", function(mo)
	mo.timer = $ + 1
	
	if not P_IsObjectOnGround(mo)
		mo.momx = FixedMul($, mo.friction)
		mo.momy = FixedMul($, mo.friction)
		mo.momz = FixedMul($, mo.friction)
	end
		
	if mo.target and mo.target.player and mo.target.player.thinkmoveangle
		P_Thrust(mo, mo.target.player.thinkmoveangle, pillarthrust / 30)
	else
		P_Thrust(mo, mo.angle, pillarthrust / 20)
	end
	
	if CBW_Battle
		local fire = P_SpawnMobjFromMobj(mo, P_RandomRange(-16, 16) * FRACUNIT, P_RandomRange(-16, 16) * FRACUNIT, 0, MT_FLAMEPARTICLE)
		fire.color = mo.color
		fire.colorized = true
		CBW_Battle.ZLaunch(fire, P_RandomRange(10, 20)*FRACUNIT/10, false)
	end
	
	if mo.timer > spawntime + 20 or (mo.target and mo.target.player and (not mo.target.player.actionstate or mo.target.player.actionstate < 3 or mo.target.player.playerstate != PST_LIVE or P_PlayerInPain(mo.target.player)))
		P_RemoveMobj(mo)
	end
end, MT_PYROSPAWNER)

addHook("MobjThinker", function(mo)
	if mo.frame & FF_FRAMEMASK == A + 32
		mo.flags = $ & ~MF_MISSILE
	end
end, MT_PYROGEYSER)

addHook("ThinkFrame", function()
	if battle_loaded or not CBW_Battle
		return
	end
	battle_loaded = true
	local B = CBW_Battle
	
	local Blaze_PreCollide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
		if plr[n1].blazeboosting
			plr[n1].blazemarker = true
		end
	end

	local Blaze_PostCollide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
		if plr[n1] and plr[n1].blazemarker
			plr[n1].blazemarker = nil
		end
	end

	local Blaze_Collide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
		if not (plr[n1] and plr[n1].blazemarker)
			return false
		end

		if not ((hurt != 1 and n1 == 1) or (hurt != -1 and n1 == 2))
		
			local shake = false
			if (mo[n1] and mo[n1].player and mo[n1].player == consoleplayer)
			or (mo[n2] and mo[n2].player and mo[n2].player == consoleplayer)
				shake = true
			end
			
			plr[n1].blazeboosting = 0
			plr[n1].blazeburstcharge = CBW_Battle.Console.BoostCharge.value*TICRATE
			
--	Check for Magnet Shield

	B.CanShieldActive = function(player)
	if not P_PlayerInPain(player)
	    and not player.blazeboosting
		and not player.gotcrystal
		and not player.gotflag
		and not player.isjettysyn
		and not player.revenge
		and not player.exiting
		and not player.actionstate
		and not player.powers[pw_nocontrol]
		and not (player.pflags&PF_SHIELDABILITY)
		return true
	end
	return false
end
	
			
	--Part of the BM visual for getting parried
	local fx = function(mo)
		for n = 0, 16
			local dust = P_SpawnMobj(mo.x,mo.y,mo.z,MT_DUST)
			if dust and dust.valid then
				P_InstaThrust(dust,mo.angle+ANGLE_22h*n,mo.scale*36)
			end
		end
	end
	
	local Blaze_Collide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
		if not (plr[n1] and plr[n1].blazemarker)
			return false
		end
		
			if plr[n1].divemarker
			//The Dive
			if (hurt != 1 and n1 == 1) or (hurt != -1 and n1 == 2)
				B.DoPlayerFlinch(plr[n1],thrust[n1]/mo[n1].scale*2, angle[n1], thrust[n1])
			end
		end
	
					
					S_StartSoundAtVolume(mo[n1],sfx_s3k49, 200)
					S_StartSound(mo[n2],sfx_s3k5f)
					if shake
						P_StartQuake(12 * FRACUNIT, 3)
					end
					
					local vfx = P_SpawnMobjFromMobj(mo[n2], 0, 0, mo[n2].height/2, MT_SPINDUST)
					if vfx.valid
						vfx.scale = mo[n2].scale * 4/5
						vfx.destscale = vfx.scale * 3
						vfx.colorized = true
						vfx.color = SKINCOLOR_BLAZING
						vfx.state = S_BCEBOOM
					end
				end
			
				
				S_StartSoundAtVolume(mo[n1],sfx_s3k49, 200)
				S_StartSound(mo[n2],sfx_s3k5f)
				if shake
					P_StartQuake(12 * FRACUNIT, 3)
				end
				
				local vfx = P_SpawnMobjFromMobj(mo[n2], 0, 0, mo[n2].height/2, MT_SPINDUST)
				if vfx.valid
					vfx.scale = mo[n2].scale * 4/5
					vfx.destscale = vfx.scale * 3
					vfx.colorized = true
					vfx.color = SKINCOLOR_BLAZING
					vfx.state = S_BCEBOOM
				end
				
			
				//The Dive 
				
			    if not (hurt != 1 and n1 == 1) or (hurt != -1 and n1 == 2)
				plr[n1].blazeboosting = 0
				plr[n1].blazeburstcharge = 0
				plr[n1].jumpfactor = FRACUNIT
				
				S_StartSoundAtVolume(mo[n1],sfx_s3k49, 200)
				S_StartSound(mo[n2],sfx_s3k5f)
				if shake
					P_StartQuake(12 * FRACUNIT, 3)
				end
				
				local vfx = P_SpawnMobjFromMobj(mo[n2], 0, 0, mo[n2].height/2, MT_SPINDUST)
				if vfx.valid
					vfx.scale = mo[n2].scale * 4/5
					vfx.destscale = vfx.scale * 3
					vfx.colorized = true
					vfx.color = SKINCOLOR_BLAZING
					vfx.state = S_BCEBOOM
				end
			end
		end
	end
	
	local BlazeSpecial = function(mo, doaction)
		local player = mo.player
		local burstdashing = mo.state == S_PLAY_SPINDASH and player.dashspeed == (player.maxdash)  

-- Restore for interesting vfx		
--		if (burstdashing)
	--	local poopy = P_SpawnGhostMobj(mo)
	--				poopy.spriteyoffset = mo.spriteyoffset
	--				poopy.color = player.blazeflamecolor
	--				poopy.colorized = true
	--				poopy.blendmode = AST_ADD
	--				poopy.destscale = mo.scale*5
		--			poopy.scalespeed = mo.scale/28
		--			poopy.fuse = 0
		--			poopy.tics = 10
		--			poopy.frame = $ & ~FF_TRANSMASK | TR_TRANS70
		--			poopy.target = mo
		--			poopy.BlazeSpecialGhost = true
		--			if poopy.tracer
		--				poopy.tracer.color = player.blazeflamecolor 
			--			poopy.tracer.colorized = true
			--			poopy.tracer.blendmode = AST_ADD
			--			poopy.tracer.destscale = mo.scale*5
				--		poopy.tracer.scalespeed = mo.scale/28
			--			poopy.tracer.fuse = 0
			--			poopy.tracer.tics = 10
			--			poopy.tracer.frame = $ & ~FF_TRANSMASK | TR_TRANS70
			--			poopy.tracer.target = mo
			--			poopy.tracer.BlazeSpecialGhost = true
			--			poopy.tracer.FuckYouScoobyDoo = true
			--		end
			--	end	
		
			
	//Action info
		if player.actionstate == 1
			if player.actiontime < divemaxchargetime then
				player.action2text = "Revving "..100*player.actiontime/divemaxchargetime.."%"
			else
				player.action2text = "Charged 100%"
			end
		end

-- Restore the following for v10 Functionality, Keep as is for v9
		
		if not(burstdashing) and player.textflash_flashing then
				player.actiontext = B.TextFlash(player.actiontext, true, player)
			end
		
			player.actionrings = 10
			if (burstdashing) then
			if (player.textflash_flashing) then --wittle hacky
				if (leveltime % 8) == 0 then
					B.SpawnFlash(mo, 10, true)
				end
			else
				B.SpawnFlash(mo, 20, true)
				B.teamSound(mo, player, sfx_tswit, sfx_tswie, 255, false)
			end
				player.actiontext = B.TextFlash("Burst Rush", (doaction == 1), player)	

	
	--	if (burstdashing) -- Remove This Line For V10 Functionality, Keep for V9
	--		player.actionrings = 10 -- Remove This Line For V10 Functionality, Keep for V9
	--		player.actiontext = "Burst Rush" -- Remove This Line For V10 Functionality, Keep for V9
		elseif player.actionstate >= 3
			player.actiontext = "Pyro Fuse"
		elseif P_IsObjectOnGround(mo)-- and not (burstdashing)	- Keep Green for v10, Ungreen for v9
			player.actionrings = 10
			player.actiontext = "Pyro Geyser"
		else
			player.actionrings = 10 --and not (burstdashing) - same deal
			player.actiontext = "Burst Dive"			
		end		
		
		-- If we're using the grounded version we immediately get boost
		
		if not (player.actionstate and player.quickdive)
			player.quickdive = false
		end
		if P_PlayerInPain(player) 
		or (player.actionstate != 3 and player.actionstate != 4 and player.blazepillars)
			if player.actionstate == 1
				B.ApplyCooldown(player,cooldown_interrupt)
			end
			if player.blazepillars
				B.ApplyCooldown(player,cooldown_pillar)
				player.blazepillars = nil
			end
			player.actionstate = 0
			player.actiontime = 0
			return
		end
		if player.actionstate == 2 and P_IsObjectOnGround(mo)
			if not player.quickdive
				B.ApplyCooldown(player,cooldown_dive)
				if player == displayplayer or player == secondarydisplayplayer
					P_StartQuake(32*FRACUNIT, 7)
				end
			else
				B.ApplyCooldown(player,cooldown_dive/10)
			end
			S_StartSound(mo, sfx_kc40)
			S_StartSound(mo, sfx_s3k70)
			local water = B.WaterFactor(mo)
			local blastspeed = 3
			local fuse = 6
			if not player.quickdive
				//Create projectile blast
				for n = 0, 23
					local p = P_SpawnMobjFromMobj(mo,0,0,0,MT_GROUNDPOUND)
					if p and p.valid then
						p.angle = mo.angle+n*ANG15,0
						P_InstaThrust(p, p.angle, FixedMul(p.info.speed, p.scale))
						p.target = mo
						
						p.momz = mo.scale*P_MobjFlip(mo)*blastspeed/water
						p.fuse = fuse
						
						//Hacks lol
						p.state = S_BLAZEJUMPFIRE
						p.color = player.blazeflamecolor
						
						p.hit_sound = sfx_s3k70
						p.block_sound = sfx_s3k47
					end
				end
			end
			player.actionstate = 0
			player.actiontime = 0
			if not player.quickdive
				player.blazeburstcharge = CBW_Battle.Console.BoostCharge.value*TICRATE
			end
		end
		
		//Chargeup period
		if player.actionstate == 1 
			player.actiontime = $ + 1
			
			local timescale = FixedDiv((player.actiontime - diveminchargetime)*FRACUNIT, divemaxchargetime*FRACUNIT)
			local speedscale = FixedMul(divespeedmultiplier, min(timescale, 1*FRACUNIT))
			local extraframes = 15
			local water = B.WaterFactor(mo)
			
			local speed = 65 - divedownwardspeed
			local dspeed = divedownwardspeed*mo.scale + FixedMul(speed*mo.scale, timescale)
			local downwardspeed = min(dspeed, 65*mo.scale)
			if player.actiontime >= divemaxchargetime then
				if (leveltime % 8 == 0)
					local spoopy = P_SpawnGhostMobj(mo)
					spoopy.spriteyoffset = mo.spriteyoffset
					spoopy.color = player.blazeflamecolor
					spoopy.colorized = true
					spoopy.blendmode = AST_ADD
					spoopy.destscale = mo.scale*5
					spoopy.scalespeed = mo.scale/28
					spoopy.fuse = 0
					spoopy.tics = 10
					spoopy.frame = $ & ~FF_TRANSMASK | TR_TRANS70
					spoopy.target = mo
					spoopy.BlazeSpecialGhost = true
					if spoopy.tracer
						spoopy.tracer.color = player.blazeflamecolor
						spoopy.tracer.colorized = true
						spoopy.tracer.blendmode = AST_ADD
						spoopy.tracer.destscale = mo.scale*5
						spoopy.tracer.scalespeed = mo.scale/28
						spoopy.tracer.fuse = 0
						spoopy.tracer.tics = 10
						spoopy.tracer.frame = $ & ~FF_TRANSMASK | TR_TRANS70
						spoopy.tracer.target = mo
						spoopy.tracer.BlazeSpecialGhost = true
						spoopy.tracer.FuckYouScoobyDoo = true
					end
				end
			end

			//Dive launch
			if player.actionstate and player.actiontime >= diveminchargetime and (not B.ButtonCheck(player, player.battleconfig_special) or (player.actiontime - diveminchargetime) >= divemaxchargetime + extraframes) then
				B.ApplyCooldown(player,cooldown_dive)
				S_StartSound(mo, sfx_blzdiv)
				S_StartSoundAtVolume(mo, sfx_s3k4e, 120)
				
				player.actionstate = 2
				player.actiontime = 0
				player.pflags = $ & ~PF_NOJUMPDAMAGE | PF_JUMPED
				
				local boom = P_SpawnMobjFromMobj(mo,0,0,0,MT_BLAZE_EXPLOSION)
				boom.scale = $*2
				mo.state = S_PLAY_JUMP
				mo.blazejumping = 10
				//B.ResetPlayerProperties(player, true, true)
				P_InstaThrust(mo, mo.angle, 50*mo.scale)
				CBW_Battle.ZLaunch(mo, -(20*mo.scale), false)
				if not player.quickdive
					if player == displayplayer or player == secondarydisplayplayer
						P_StartQuake(18*FRACUNIT, 7)
					end
				end
			elseif player.actionstate and player.actiontime < diveminchargetime and (not B.ButtonCheck(player, player.battleconfig_special)) then
				B.ApplyCooldown(player,TICRATE)
				S_StartSound(mo, sfx_blzdiv)
				S_StartSoundAtVolume(mo, sfx_s3k4e, 120)
				
				player.actionstate = 2
				player.actiontime = 0
				player.pflags = $ & ~PF_NOJUMPDAMAGE | PF_JUMPED
				
				local boom = P_SpawnMobj(mo.x, mo.y, mo.z, MT_BLAZE_EXPLOSION)
				boom.scale = $*2
				mo.state = S_PLAY_JUMP
				mo.blazejumping = 0
				//B.ResetPlayerProperties(player, true, true)
				P_InstaThrust(mo, mo.angle, 42*mo.scale)
				CBW_Battle.ZLaunch(mo, -(20*mo.scale), false)
				player.quickdive = true
			
			//Dive charging
			else

				mo.momz = 0
				player.drawangle = mo.angle
				local speed = FixedHypot(mo.momx,mo.momy)
				if speed > mo.scale then
					local dir = R_PointToAngle2(0,0,mo.momx,mo.momy)
					P_InstaThrust(mo,dir,FixedMul(speed,mo.friction))
				end

			end
			return
		end
		//Dive travel
		if player.actionstate == 2
			player.actiontime = $ + 1
			if (mo.momz * P_MobjFlip(mo)) <= 0
				if not player.quickdive
					mo.blazejumping = 10
					mo.state = S_PLAY_JUMP
					player.pflags = ($ | PF_JUMPED | PF_THOKKED)
					CBW_Battle.ZLaunch(mo, -(20*mo.scale), false)
					local g = P_SpawnGhostMobj(mo)
					g.destscale = $ * 2
					g.blendmode = AST_ADD
					g.colorized = true
					g.color = skins[mo.skin].prefcolor
					g.frame = ($ & ~FF_TRANSMASK) | TR_TRANS90
				else
					mo.blazejumping = 0
					mo.state = S_PLAY_JUMP
					player.pflags = ($ | PF_JUMPED | PF_THOKKED)
					CBW_Battle.ZLaunch(mo, -(20*mo.scale), false)
					local g = P_SpawnGhostMobj(mo)
					g.destscale = $ * 2
					g.blendmode = AST_ADD
					g.colorized = true
					g.color = skins[mo.skin].prefcolor
					g.frame = ($ & ~FF_TRANSMASK) | TR_TRANS90
					g.fuse = $ - 2
				end
			else
				mo.blazejumping = 0
				player.actionstate = 0
				player.actiontime = 0
				B.ResetPlayerProperties(player, false, true)
				mo.state = S_PLAY_SPRING
			end
			return
		end	
			
		//Pillar spawn twirl
       
		if player.actionstate == 3
			player.pflags = $ | PF_JUMPED
			mo.state = S_PLAY_ROLL
			mo.frame = (player.actiontime) % 4
			if player.actiontime >= 4
				mo.frame = (player.actiontime/2 + 2) % 4
			end
			
			player.actiontime = $ + 1
			if player.actiontime >= 10
				player.pflags = $ & ~PF_JUMPED
				player.actionstate = 4
				player.actiontime = 0
				mo.state = S_PLAY_WALK
				player.pflags = $ & ~PF_SPINNING
			end
			return
		end
		
		if player.actionstate == 4 and player.blazepillars
			player.actiontime = $ + 1
			if (doaction == 1 and player.actiontime > 5) or player.actiontime >= spawntime
				dopillars(player)
				S_StartSoundAtVolume(nil, sfx_s3k9c, 100, player)
				P_SpawnMobjFromMobj(mo, 0, 0, mo.height/2, MT_SUPERSPARK)
				local g = P_SpawnGhostMobj(mo)
				g.destscale = $ * 2
				g.blendmode = AST_ADD
				g.colorized = true
				g.color = SKINCOLOR_WHITE
				B.ApplyCooldown(player,cooldown_pillar)
				player.actionstate = 0
				player.actiontime = 0
				player.blazepillars = nil	
			end
			return
		end
		
		//Activating the special move
		if doaction != 1 
			return
		end
		
		B.PayRings(player)
		
		//Ground special
		if P_IsObjectOnGround(mo) and not (burstdashing)
			S_StartSound(mo, sfx_s3k70)
			
		
			
			player.actionstate = 3
		
			player.pflags = $ | PF_JUMPED
			mo.state = S_PLAY_JUMP
			
			local g = P_SpawnGhostMobj(mo)
			g.color = SKINCOLOR_YELLOW
			g.colorized = true
			g.destscale = g.scale * 2
			
			local angles = {0, -spread * 180, spread * 180}
			player.blazepillars = {}
			
			for i = 1, 3
				local disc = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_PYROSPAWNER)
				player.blazepillars[i] = disc
				disc.target = mo
				disc.angle = mo.angle
				disc.color = player.blazeflamecolor
				disc.timer = 0
				P_Thrust(disc, mo.angle + angles[i], pillarthrust)
				P_Thrust(disc, mo.angle, player.speed)
				S_StartSoundAtVolume(disc, sfx_s3kc2l, 80)	    
			end	
			
			mo.momx = $ / 2
			mo.momy = $ / 2
			
		//Air special
		elseif (burstdashing) or not P_IsObjectOnGround(mo)
		    player.filler = player.blazeburstcharge
			S_StartSound(mo, sfx_blzrev)
			mo.state = S_PLAY_BLAZE_SPINDASH
			player.pflags = $ | PF_FULLSTASIS & ~PF_JUMPED & ~PF_SHIELDABILITY & ~PF_SPINNING

			player.blazehover = false
			player.blazehoverpower = 1
			player.blazehovertimer = 0
			player.mo.blazejumping = 0
			
			player.actionstate = 1	
			player.actiontime = 0
		end
	end
	
	local BlazePriority = function(player)
		local mo = player.mo
		local spinjump = (player.pflags&PF_JUMPED and not(player.pflags&PF_NOJUMPDAMAGE))
		local spinning = (mo.state == S_PLAY_BLAZE_SPIN) or (mo.state == S_PLAY_ROLL)
		if player.blazeboosting
			B.SetPriority(player,1,1,"amy_melee",3,1,"Flame Boost")
		elseif player.actionstate == 1 then
			B.SetPriority(player,0,0,nil,0,0,"burst dive charge")
		elseif player.actionstate == 2 then
				if player.quickdive
					B.SetPriority(player,1,1,nil,1,1,"Burst Dive")
				else
					B.SetPriority(player,3,1,nil,3,1,"Burst Dive")
				end
		elseif player.actionstate == 3 or (spinning and not spinjump)
			B.SetPriority(player,1,1,nil,1,1,"Axel Spin")
		elseif mo.blazejumping
			B.SetPriority(player,1,1,"tails_fly",1,1,"Accelerator Tornado")
		elseif spinjump
			B.SetPriority(player,1,1,nil,1,1,"Axel Jump")
		end
	end
	
	B.SkinVars["blaze"] = {
		weight = 90,
		shields = 0,
		special = BlazeSpecial,
		func_priority = BlazePriority,
		func_precollide = Blaze_PreCollide,
		func_collide = Blaze_Collide,
		func_postcollide = Blaze_PostCollide
	}
	
	print("\x89\Blaze is boosting near!")
end)

addHook("MobjDeath",function(monitor,blaze)
	if monitor.valid and monitor.flags & MF_MONITOR
		if blaze.player and blaze.valid and blaze.skin == "blaze"
			if blaze.player.actionstate then
				blaze.player.blazehovertimer = 88
				blaze.player.pflags = $|PF_JUMPED|PF_THOKKED
			end
		end
	end
end)
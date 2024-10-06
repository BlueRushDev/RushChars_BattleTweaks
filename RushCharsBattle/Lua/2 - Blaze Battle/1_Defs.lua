freeslot("MT_PYROSPAWNER", "MT_PYROGEYSER", "S_PYROSPAWNER", "S_PYROGEYSER", "SPR_PGIN", "SPR_PGPL", "sfx_blzdiv", "sfx_blzgsr")

sfxinfo[sfx_blzdiv].caption = "Burst"
sfxinfo[sfx_blzgsr].caption = "Powerful flames"

mobjinfo[MT_PYROSPAWNER] = {
	spawnstate = S_PYROSPAWNER,
	radius = 30*FRACUNIT,
	height = 8*FRACUNIT,
	flags = MF_NOGRAVITY
}

mobjinfo[MT_PYROGEYSER] = {
	spawnstate = S_PYROGEYSER,
	radius = 30*FRACUNIT,
	height = 240*FRACUNIT,
	flags = MF_MISSILE|MF_NOGRAVITY|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT
}
mobjinfo[MT_PYROGEYSER].name = "Pyro Geyser"

states[S_PYROSPAWNER] = {
	sprite = SPR_PGIN,
	frame = FF_FULLBRIGHT|FF_ANIMATE|A,
	var1 = 3,
	var2 = 1,
	tics = -1
}

states[S_PYROGEYSER] = {
	sprite = SPR_PGPL,
	frame = FF_FULLBRIGHT|FF_ANIMATE|A,
	var1 = R_Char2Frame('l') - 1,
	var2 = 1,
	tics = R_Char2Frame('l')
}

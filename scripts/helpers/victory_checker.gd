class_name VictoryChecker extends Node

static func check(level: BaseLevel):
	if level.victory_triggered or level.initializing:
		return
	var ai_has_planets := false
	var human_has_planets := false
	#See who has planets if level is done initializing and no victory
	for player in level.players:
		if player is BlinkyAI and player.my_planets.size() > 0:
			ai_has_planets = true
		elif player is Human and player.my_planets.size() > 0:
			human_has_planets = true
	# Human has no planets, can't trigger victory
	if not human_has_planets:
		return
	# AI still has planets, no victory yet
	if ai_has_planets:
		return
	# If we reached this point, human controls all planets
	level.on_victory()

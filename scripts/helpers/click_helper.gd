class_name ClickHelper extends Node

static func handle_click(level: BaseLevel, clicked: BasePlanet) -> BasePlanet:
	var human_player: BasePlayer = null
	# Check if a planet is already selected, attempt to send ships
	if level.selected_planet:
		if level.selected_planet != clicked:
			for p in level.players:
				if p is Human:
					human_player = p
					break
			if human_player:
				var ships_available = level.selected_planet.orbit.get_ships_for_player(human_player)
				if level.selected_planet.controlling_player == human_player or ships_available > 0:
					human_player.level.send_ships(level.selected_planet, clicked)
		return null
	# No planet selected yet, select if human-controlled or has human ships
	for p in level.players:
		if p is Human:
			human_player = p
			break
	if human_player:
		var ships_available = clicked.orbit.get_ships_for_player(human_player)
		if clicked.controlling_player == human_player or ships_available > 0:
			return clicked
	# Nothing selected
	return null

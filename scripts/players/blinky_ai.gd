class_name BlinkyAI extends BaseAI

func _ready():
	color = Color.INDIAN_RED

func think():
	if not queries or my_planets.is_empty():
		return

	var targets = queries.get_not_player(self)

	for planet in my_planets:
		if planet.orbit.count() < data.min_ships_to_send:
			continue

		if planet.orbit.is_in_combat():
			var my_ships = planet.orbit.get_ships_for_player(self)
			var enemy_ships = planet.orbit.count() - my_ships
			if my_ships < enemy_ships:
				continue

		var target := queries.get_closest_planet(planet, targets)
		if target:
			level.send_ships(planet, target, self)

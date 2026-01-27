class_name Combat

static func resolve_orbit_combat(fleets: Dictionary, delta: float) -> Dictionary:
	var destroyed: Array[Ship] = []

	# Calculate DPS PER PLAYER
	var dps := {}
	for player in fleets.keys():
		var ship_count: int = fleets[player].size()
		dps[player] = ship_count * player.fleet_dps

	# Apply damage over time
	for target_player in fleets.keys():
		var incoming := 0.0

		for attacker in dps.keys():
			if attacker != target_player:
				incoming += dps[attacker] * delta

		while incoming >= 1.0 and fleets[target_player].size() > 0:
			var ship: Ship = fleets[target_player].pop_back()
			incoming -= 1.0
			destroyed.append(ship)

	return {
		"destroyed": destroyed
	}

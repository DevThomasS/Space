class_name Combat

# fleets: { BasePlayer : Array[Ship] }
# Returns a dictionary:
#   destroyed: Array[Ship]
#   winner: BasePlayer or null
#   remaining: Dictionary{BasePlayer: int}
static func resolve_orbit_combat(fleets: Dictionary) -> Dictionary:
	var dps := {}
	# Compute total DPS per player
	for player in fleets.keys():
		var total := 0.0
		for ship in fleets[player]:
			total += ship.strength
		dps[player] = total

	var destroyed := []
	var remaining_counts := {}
	
	# Resolve combat: each target takes damage from all others
	for target in fleets.keys():
		var incoming := 0.0
		for attacker in dps.keys():
			if attacker != target:
				incoming += dps[attacker]
		var remaining: int = fleets[target].size()
		for fleet in fleets[target]:
			if incoming <= 0:
				break
			incoming -= fleet.strength
			destroyed.append(fleet)
			remaining -= 1
		remaining_counts[target] = remaining

	# Determine winner if only one player has surviving ships
	var active_players := []
	for player in remaining_counts.keys():
		if remaining_counts[player] > 0:
			active_players.append(player)
	
	var winner: BasePlayer = null
	if active_players.size() == 1:
		winner = active_players[0]

	return {
		"destroyed": destroyed,
		"winner": winner,
		"remaining": remaining_counts
	}

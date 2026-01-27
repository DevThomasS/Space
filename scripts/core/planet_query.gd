class_name PlanetQuery extends Node

func get_all() -> Array[Planet]:
	var result: Array[Planet] = []
	for n in get_tree().get_nodes_in_group("planets"):
		var planet := n as Planet
		if planet:
			result.append(planet)
	return result

func get_by_player(player: BasePlayer) -> Array[Planet]:
	var result: Array[Planet] = []
	for planet in get_all():
		if planet.controlling_player == player:
			result.append(planet)
	return result

func get_not_player(player: BasePlayer) -> Array[Planet]:
	var result: Array[Planet] = []
	for planet in get_all():
		if planet.controlling_player != player:
			result.append(planet)
	return result

func get_closest_planet(from: Planet, targets: Array[Planet]) -> Planet:
	var best: Planet = null
	var best_dist := INF
	for t in targets:
		var d := from.global_position.distance_to(t.global_position)
		if d < best_dist:
			best_dist = d
			best = t
	return best

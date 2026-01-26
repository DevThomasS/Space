class_name PlanetQuery extends Node

func get_by_faction(faction: Planet.Faction) -> Array[Planet]:
	var result: Array[Planet] = []

	for n in get_tree().get_nodes_in_group("planets"):
		var planet := n as Planet
		if planet and planet.faction == faction:
			result.append(planet)

	return result

func get_not_faction(faction: Planet.Faction) -> Array[Planet]:
	var result: Array[Planet] = []

	for n in get_tree().get_nodes_in_group("planets"):
		var planet := n as Planet
		if planet and planet.faction != faction:
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

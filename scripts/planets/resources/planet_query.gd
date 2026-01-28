class_name PlanetQuery extends Resource

var tree: SceneTree

func setup(scene_tree: SceneTree) -> void:
	tree = scene_tree

func get_planets() -> Array[BasePlanet]:
	var result: Array[BasePlanet] = []
	for n in tree.get_nodes_in_group("planets"):
		var planet := n as BasePlanet
		if planet:
			result.append(planet)
	return result

func get_by_player(player: BasePlayer) -> Array[BasePlanet]:
	var result: Array[BasePlanet] = []
	for planet in get_planets():
		if planet.controlling_player == player:
			result.append(planet)
	return result

func get_not_player(player: BasePlayer) -> Array[BasePlanet]:
	var result: Array[BasePlanet] = []
	for planet in get_planets():
		if planet.controlling_player != player:
			result.append(planet)
	return result

func get_closest_planet(from: BasePlanet, targets: Array[BasePlanet]) -> BasePlanet:
	var best: BasePlanet = null
	var best_dist := INF
	for t in targets:
		var d := from.global_position.distance_to(t.global_position)
		if d < best_dist:
			best_dist = d
			best = t
	return best

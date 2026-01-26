class_name BaseLevel extends Node2D

@onready var fleets := $Fleets

var send_fraction := 0.5

func _ready():
	for planet in get_tree().get_nodes_in_group("planets"):
		planet.level_ref = self

func check_victory() -> void:
	var planets = get_tree().get_nodes_in_group("planets")
	for planet in planets:
		if planet.faction == Planet.Faction.AI:
			return
	print("Victory! Returning to main menu...") #TODO: just for now for clarity of change
	get_tree().call_deferred("change_scene_to_file", "res://scenes/levels/main_menu.tscn")

func send_ships(from: Planet, to: Planet):
	if not from or not to:
		return
	var orbit := from.orbit
	var total := orbit.count()
	if total == 0:
		return
	var to_send := int(total * send_fraction)
	to_send = max(to_send, 1)
	for i in range(to_send):
		if orbit.count() == 0:
			break
		var ship := orbit.ships[0]
		from.remove_orbit_ship(ship)
		ship.state = ship.State.TRAVELING
		ship.from_planet = from
		ship.to_planet = to
		ship.global_position = from.global_position
		ship.t = 0.0
		fleets.add_child(ship)

func get_planet_at_mouse() -> Planet:
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var result := space.intersect_point(query)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

class_name Game extends Node2D

@onready var ship_scene = preload("res://scenes/Ship.tscn")
@export var ai_send_interval := 2.5

var ai_timer := 0.0
var selected_planet: Node2D = null
var send_fraction := 0.5

func _process(delta):
	ai_timer += delta
	if ai_timer >= ai_send_interval:
		ai_timer = 0.0
		ai_turn()

func ai_turn():
	var ai_planets = get_planets_by_faction(Planet.Faction.AI)
	var targets = get_planets_not_faction(Planet.Faction.AI)

	for planet in ai_planets:
		if planet.available_ships() < 10:
			continue

		var target = targets.pick_random()
		send_ships(planet, target)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var clicked = get_planet_at_mouse()
		if clicked:
			handle_planet_click(clicked)

func get_planets_by_faction(faction):
	return get_tree().get_nodes_in_group("planets").filter(
		func(n): return n.faction == faction
	)

func get_planets_not_faction(faction):
	return get_tree().get_nodes_in_group("planets").filter(
		func(n): return n.faction != faction
	)

func get_planet_at_mouse():
	var space = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true

	var result = space.intersect_point(query)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func handle_planet_click(planet):
	if selected_planet == null:
		selected_planet = planet
	else:
		send_ships(selected_planet, planet)
		selected_planet = null

func send_ships(from_planet, to_planet):
	var orbit = from_planet.orbit
	var total = orbit.get_child_count()

	if total == 0:
		return
	
	var to_send := int(total * send_fraction)
	to_send = max(to_send, 1)

	for i in range(to_send):
		var ship = orbit.get_child(0)
		orbit.remove_child(ship)

		ship.state = ship.State.TRAVELING
		ship.from_planet = from_planet
		ship.to_planet = to_planet
		ship.global_position = from_planet.global_position

		$Fleets.add_child(ship)

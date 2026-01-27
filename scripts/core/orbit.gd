class_name Orbit extends Node2D

signal combat_started
signal combat_resolved(result) # result is dictionary from Combat

@export var radius := 48.0
@export var rotation_speed := 0.3

var ships: Array[Ship] = []
var in_combat := false

func _process(delta):
	rotation += rotation_speed * delta

func add_ship(ship: Ship) -> void:
	if ship.get_parent():
		ship.get_parent().remove_child(ship)
	add_child(ship)
	ships.append(ship)
	update_positions()
	check_for_combat()

func remove_ship(ship: Ship) -> void:
	if ship in ships:
		ships.erase(ship)
	if ship.get_parent() == self:
		remove_child(ship)
	update_positions()

func count() -> int:
	return ships.size()

func update_positions():
	var ship_count := ships.size()
	if ship_count == 0:
		return
	for i in range(ship_count):
		var angle := TAU * float(i) / float(ship_count)
		ships[i].position = Vector2(cos(angle), sin(angle)) * radius

# --- Combat ---

func check_for_combat():
	var fleets := get_fleets()
	if fleets.size() <= 1:
		if in_combat:
			in_combat = false
			var winner: BasePlayer = null
			if fleets.size() == 1:
				winner = fleets.keys()[0]
			emit_signal("combat_resolved", {"winner": winner, "destroyed": [], "remaining": {}})
		return
	
	if not in_combat:
		in_combat = true
		emit_signal("combat_started")
	resolve_combat(fleets)

func resolve_combat(fleets: Dictionary) -> void:
	var result := Combat.resolve_orbit_combat(fleets)
	
	# Remove destroyed ships
	for ship in result["destroyed"]:
		remove_ship(ship)
		ship.queue_free()

	update_positions()
	
	emit_signal("combat_resolved", result)

func get_fleets() -> Dictionary:
	var fleets := {}
	for ship in ships:
		if ship.controlling_player == null:
			continue
		if not fleets.has(ship.controlling_player):
			fleets[ship.controlling_player] = []
		fleets[ship.controlling_player].append(ship)
	return fleets

class_name Orbit extends Node2D

signal combat_started
signal combat_resolved(result)

@export var data: OrbitData

var ships: Array[Ship] = []
var in_combat := false
var combat_timer := 0.0
var ship_destroyed_sound: AudioStreamPlayer

func _process(delta):
	rotation += data.rotation_speed * delta

	if in_combat:
		combat_timer += delta
		if combat_timer >= data.combat_tick_rate:
			combat_timer = 0.0
			_tick_combat()

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
		ships[i].position = Vector2(cos(angle), sin(angle)) * data.radius

# -------------------------------------------------
# Combat control
# -------------------------------------------------

func check_for_combat():
	var fleets := get_fleets()

	if fleets.size() <= 1:
		if in_combat:
			_end_combat(fleets)
		return

	if not in_combat:
		in_combat = true
		combat_timer = 0.0
		emit_signal("combat_started")

func _tick_combat():
	var fleets := get_fleets()
	if fleets.size() <= 1:
		_end_combat(fleets)
		return
	var result := Combat.resolve_orbit_combat(fleets, data.combat_tick_rate)
	for ship in result.destroyed:
		if ship_destroyed_sound:
			play_destroy_ship_sound(ship)
		remove_ship(ship)
		ship.queue_free()
	update_positions()

func play_destroy_ship_sound(ship: Ship) -> void:
	# Duplicate the sound player for overlapping play
	var temp = ship_destroyed_sound.duplicate() as AudioStreamPlayer
	ship.get_parent().add_child(temp)
	temp.pitch_scale += (randf() - 0.5) * 0.4  # ±0.2 variation
	temp.volume_db += (randf() - 0.5) * 4.0    # ±2 dB variation
	temp.play()
	temp.finished.connect(Callable(temp, "queue_free"))

func _end_combat(fleets: Dictionary):
	in_combat = false
	combat_timer = 0.0

	var winner: BasePlayer = null
	if fleets.size() == 1:
		winner = fleets.keys()[0]

	emit_signal("combat_resolved", {
		"winner": winner,
		"destroyed": [],
		"remaining": {}
	})

func get_fleets() -> Dictionary:
	var fleets := {}
	for ship in ships:
		if ship.controlling_player == null:
			continue
		if not fleets.has(ship.controlling_player):
			fleets[ship.controlling_player] = []
		fleets[ship.controlling_player].append(ship)
	return fleets

func is_in_combat() -> bool:
	return in_combat

func get_ships_for_player(player: BasePlayer) -> int:
	var ship_count := 0
	for ship in ships:
		if ship.controlling_player == player:
			ship_count += 1
	return ship_count

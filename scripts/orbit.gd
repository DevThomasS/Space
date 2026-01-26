class_name Orbit extends Node2D

@export var radius := 48.0
@export var rotation_speed := 0.3

var ships: Array[Ship] = []

func _process(delta):
	rotation += rotation_speed * delta

func add_ship(ship: Ship) -> void:
	add_child(ship)
	ships.append(ship)
	update_positions()

func remove_ship(ship: Ship) -> void:
	if ship in ships:
		ships.erase(ship)
		if ship.get_parent() == self:
			remove_child(ship)
		update_positions()

func count() -> int:
	return ships.size()

func update_positions() -> void:
	var ship_count := ships.size()
	if ship_count == 0:
		return

	for i in range(ship_count):
		var angle := TAU * float(i) / float(ship_count)
		ships[i].position = Vector2(
			cos(angle),
			sin(angle)
		) * radius

class_name Planet extends Node2D

enum Faction { NEUTRAL, PLAYER, AI }

@export var faction: Faction = Faction.NEUTRAL
@export var spawn_rate := 0.5 # ships per second
@export var max_ships := 50

@onready var sprite := $Sprite2D
@onready var orbit := $Orbit

const ORBIT_RADIUS := 48.0
const ORBIT_SPACING := 12.0

var orbit_ships: Array[Node2D] = []
var spawn_timer := 0.0
var defenders := 0

func _ready():
	z_index = 1
	defenders = orbit.get_child_count()
	update_color()

func update_color():
	match faction:
		Faction.NEUTRAL:
			sprite.modulate = Color.GRAY
		Faction.PLAYER:
			sprite.modulate = Color.CORNFLOWER_BLUE
		Faction.AI:
			sprite.modulate = Color.INDIAN_RED

func _process(delta):
	if faction == Faction.NEUTRAL || orbit.get_child_count() >= max_ships:
		return

	spawn_timer += delta
	orbit.rotation += 0.3 * delta
	if spawn_timer >= 0.5 / spawn_rate:
		spawn_timer = 0.0
		spawn_ship()

func spawn_ship():
	var ship = preload("res://scenes/Ship.tscn").instantiate()
	orbit.add_child(ship)
	orbit_ships.append(ship)
	defenders += 1
	update_orbit_positions()

func receive_ship():
	if faction == Faction.NEUTRAL:
		faction = Faction.PLAYER
		update_color()
		defenders = 1
		return

	defenders -= 1

	if defenders < 0:
		faction = Faction.PLAYER
		update_color()
		defenders = abs(defenders)

func available_ships() -> int:
	return orbit.get_child_count()

func remove_orbit_ship(ship: Ship) -> void:
	if ship.get_parent():
		ship.get_parent().remove_child(ship)
	orbit_ships.erase(ship)
	update_orbit_positions()

func update_orbit_positions() -> void:
	var count := orbit_ships.size()
	if count == 0:
		return

	for i in orbit_ships.size():
		var ship := orbit_ships[i]
		var angle := TAU * float(i) / float(count)
		var radius := ORBIT_RADIUS
		ship.position = Vector2(
			cos(angle),
			sin(angle)
		) * radius

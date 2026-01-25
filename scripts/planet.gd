class_name Planet extends Node2D

enum Faction { NEUTRAL, PLAYER, AI }

@export var faction: Faction = Faction.NEUTRAL
@export var spawn_rate := 0.5 # ships per second
@export var max_ships := 50

@onready var sprite := $Sprite2D
@onready var orbit := $Orbit

var spawn_timer := 0.0
var defenders := 0

func _ready():
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
	ship.state = ship.State.ORBITING
	ship.angle = randf() * TAU
	orbit.add_child(ship)

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

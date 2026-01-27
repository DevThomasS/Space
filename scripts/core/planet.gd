class_name Planet extends Node2D

enum Faction { NEUTRAL, PLAYER, AI }

@export var faction: Faction = Faction.NEUTRAL
@export var spawn_rate := 1.0
@export var max_ships := 50

@onready var sprite := $Sprite2D
@onready var orbit: Orbit = $Orbit

var spawn_timer := 0.0
var defenders := 0
var level_ref: BaseLevel

func _ready():
	z_index = 1
	defenders = orbit.count()
	update_color()

func update_color():
	match faction:
		Faction.NEUTRAL:
			sprite.modulate = Color.GRAY
		Faction.PLAYER:
			sprite.modulate = Color.CORNFLOWER_BLUE
		Faction.AI:
			sprite.modulate = Color.INDIAN_RED
	if level_ref:
		level_ref.call_deferred("check_victory")

func _process(delta):
	if faction == Faction.NEUTRAL:
		return
	if orbit.count() >= max_ships:
		return
	spawn_timer += delta
	if spawn_timer >= 1.0 / spawn_rate:
		spawn_timer = 0.0
		spawn_ship()

func spawn_ship():
	var ship := preload("res://scenes/Ship.tscn").instantiate()
	orbit.add_ship(ship)
	defenders += 1

func available_ships() -> int:
	return orbit.count()

func remove_orbit_ship(ship: Ship) -> void:
	orbit.remove_ship(ship)
	defenders = max(defenders - 1, 0)

func receive_ship(from_faction: Faction):
	if from_faction == faction:
		add_reinforcement()
		return
	defenders -= 1
	if defenders < 0:
		faction = from_faction
		update_color()
		defenders = abs(defenders)

func add_reinforcement():
	var ship := preload("res://scenes/Ship.tscn").instantiate()
	orbit.add_ship(ship)
	defenders += 1

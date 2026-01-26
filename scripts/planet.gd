class_name Planet extends Node2D

enum Faction { NEUTRAL, PLAYER, AI }

@export var faction: Faction = Faction.NEUTRAL
@export var spawnRate := 1.0
@export var maxShips := 50

@onready var sprite := $Sprite2D
@onready var orbit: Orbit = $Orbit

var spawnTimer := 0.0
var defenders := 0

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

func _process(delta):
	if faction == Faction.NEUTRAL:
		return
	if orbit.count() >= maxShips:
		return
	spawnTimer += delta
	if spawnTimer >= 1.0 / spawnRate:
		spawnTimer = 0.0
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

func receive_ship(fromFaction: Faction):
	if fromFaction == faction:
		add_reinforcement()
		return
	defenders -= 1
	if defenders < 0:
		faction = fromFaction
		update_color()
		defenders = abs(defenders)

func add_reinforcement():
	var ship := preload("res://scenes/Ship.tscn").instantiate()
	orbit.add_ship(ship)
	defenders += 1

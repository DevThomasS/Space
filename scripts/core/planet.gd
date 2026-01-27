class_name Planet extends Node2D

signal owner_changed(new_owner: BasePlayer)

@export var spawn_rate := 1.0
@export var max_ships := 30

@onready var orbit: Orbit = $Orbit
@onready var button: Button = $Button

var spawn_timer := 0.0
var defenders := 0
var controlling_player: BasePlayer = null
var is_selected := false

func _ready():
	z_index = 1
	add_to_group("planets")
	defenders = orbit.count()
	call_deferred("update_color")

# Called every frame to spawn ships
func _process(delta):
	if controlling_player == null or orbit.count() >= max_ships:
		return

	spawn_timer += delta
	if spawn_timer >= 1.0 / spawn_rate:
		spawn_timer = 0.0
		spawn_ship()

# --- Ownership ---
func set_controlling_player(player: BasePlayer) -> void:
	if controlling_player == player:
		return
	var previous_owner := controlling_player
	if previous_owner:
		previous_owner.remove_planet(self)
	controlling_player = player
	update_color()
	owner_changed.emit(player)
	if controlling_player:
		controlling_player.add_planet(self)
	if controlling_player and controlling_player.level:
		controlling_player.level.check_victory()

func update_color():
	var c := Color(0.745, 0.745, 0.745, 1)
	if controlling_player:
		c = controlling_player.color
		if is_selected:
			c = c.lightened(0.2)
	button.modulate = c

# --- Ships ---
func spawn_ship():
	var ship := preload("res://scenes/core/ship.tscn").instantiate()
	orbit.add_ship(ship)
	defenders += 1

func available_ships() -> int:
	return orbit.count()

func remove_orbit_ship(ship: Ship) -> void:
	orbit.remove_ship(ship)
	defenders = max(defenders - 1, 0)

func receive_ship(from_player: BasePlayer):
	if from_player == null:
		return
	if controlling_player == from_player:
		add_reinforcement()
		return
	defenders -= 1
	if defenders < 0:
		set_controlling_player(from_player)
		defenders = abs(defenders)

func add_reinforcement():
	var ship := preload("res://scenes/core/ship.tscn").instantiate()
	orbit.add_ship(ship)
	defenders += 1

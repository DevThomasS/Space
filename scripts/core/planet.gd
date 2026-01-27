class_name Planet extends Node2D

signal owner_changed(new_owner)

@export var spawn_rate := 1.0
@export var max_ships := 30
@export var capture_time := 5.0

@onready var orbit: Orbit = $Orbit
@onready var button: Button = $Button

var spawn_timer := 0.0
var controlling_player: BasePlayer
var is_selected := false

var contested := false
var capture_timer := 0.0
var pending_owner: BasePlayer

func _ready():
	z_index = 1
	add_to_group("planets")
	call_deferred("update_color")

	orbit.combat_started.connect(_on_combat_started)
	orbit.combat_resolved.connect(_on_combat_resolved)

func _process(delta):
	if contested:
		capture_timer -= delta
		if capture_timer <= 0 and pending_owner:
			set_controlling_player(pending_owner)
			contested = false
			pending_owner = null
		return

	if not controlling_player or orbit.count() >= max_ships:
		return

	spawn_timer += delta
	if spawn_timer >= 1.0 / spawn_rate:
		spawn_timer = 0.0
		spawn_ship()

func receive_ship(ship: Ship):
	if ship == null:
		return
	orbit.add_ship(ship)

func _on_combat_started():
	# Defender advantage: planet continues spawning ships
	pass

func _on_combat_resolved(result: Dictionary):
	var winner: BasePlayer = result.get("winner", null)
	if winner == null:
		return
	
	if winner != controlling_player:
		# Begin capture process
		contested = true
		pending_owner = winner
		capture_timer = capture_time

func spawn_ship():
	if controlling_player == null:
		return
	var ship := preload("res://scenes/core/ship.tscn").instantiate()
	ship.controlling_player = controlling_player
	orbit.add_ship(ship)

func set_controlling_player(player: BasePlayer):
	if controlling_player == player:
		return

	if controlling_player:
		controlling_player.remove_planet(self)

	controlling_player = player
	update_color()
	owner_changed.emit(player)

	if controlling_player:
		controlling_player.add_planet(self)
		if controlling_player.level:
			controlling_player.level.check_victory()

func update_color():
	var c := Color(0.75, 0.75, 0.75)
	if controlling_player:
		c = controlling_player.color
		if is_selected:
			c = c.lightened(0.2)
	button.modulate = c

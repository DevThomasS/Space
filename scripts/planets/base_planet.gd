class_name BasePlanet extends Node2D

signal owner_changed(new_owner)

@export var data: PlanetData

@onready var orbit: Orbit = $Orbit
@onready var button: Button = $Button
@onready var capture_bar: ColorRect = $CaptureBar
@onready var capture_sound: AudioStreamPlayer = $CaptureSound
@onready var ship_destroyed_sound: AudioStreamPlayer = $ShipDestroyedSound

var spawn_timer := 0.0
var controlling_player: BasePlayer
var is_selected := false
var contested := false
var capture_timer := 0.0
var pending_owner: BasePlayer

func _ready():
	z_index = 1
	call_deferred("update_color")
	# Setup capture bar
	capture_bar.visible = false
	capture_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capture_bar.color.a = 0.0
	# Connect orbit signals
	orbit.combat_started.connect(_on_combat_started)
	orbit.combat_resolved.connect(_on_combat_resolved)
	orbit.ship_destroyed_sound = ship_destroyed_sound

func _process(delta):
	handle_capture(delta)
	handle_spawn(delta)

func handle_capture(delta):
	if not contested:
		return # nothing to do

	if orbit.in_combat:
		return # do not progress capture during combat

	capture_timer -= delta

	if pending_owner:
		var ratio: float = clamp((data.capture_time - capture_timer) / data.capture_time, 0.0, 1.0)
		capture_bar.visible = true
		capture_bar.color = pending_owner.color
		capture_bar.color.a = ratio

	if capture_timer <= 0 and pending_owner:
		set_controlling_player(pending_owner)
		contested = false
		pending_owner = null

func _reset_capture():
	contested = false
	pending_owner = null
	capture_timer = 0.0
	_reset_capture_bar()

func _reset_capture_bar():
	if capture_bar:
		capture_bar.visible = false
		capture_bar.color.a = 0.0

# ----------------- Spawning logic -----------------
func handle_spawn(delta):
	if not controlling_player or orbit.count() >= data.max_ships:
		return # nothing to spawn

	spawn_timer += delta
	if spawn_timer >= 1.0 / data.spawn_interval:
		spawn_timer = 0.0
		spawn_ship()

func spawn_ship():
	if controlling_player == null:
		return # sanity check

	var ship := preload("res://scenes/core/ship.tscn").instantiate()
	ship.controlling_player = controlling_player
	if ship.sprite:
		ship.sprite.modulate = controlling_player.color
	orbit.add_ship(ship)

func receive_ship(ship: Ship):
	if ship == null:
		return # sanity

	orbit.add_ship(ship)

	if controlling_player == null and not contested and not orbit.in_combat:
		contested = true
		pending_owner = ship.controlling_player
		capture_timer = data.capture_time

# ----------------- Combat callbacks -----------------
func _on_combat_started():
	pass # Placeholder for UI or other effects

func _on_combat_resolved(result: Dictionary):
	var winner: BasePlayer = result.get("winner", null)

	if winner == null:
		_reset_capture()
		return

	if controlling_player != winner:
		contested = true
		pending_owner = winner
		capture_timer = data.capture_time

		# Visual update immediately
		capture_bar.visible = true
		capture_bar.color = winner.color
		capture_bar.color.a = 0.0

# ----------------- Ownership -----------------
func set_controlling_player(player: BasePlayer):
	if controlling_player == player:
		return # no change

	if controlling_player:
		controlling_player.remove_planet(self)

	controlling_player = player
	update_color()
	owner_changed.emit(player)

	if capture_sound:
		capture_sound.play()

	if controlling_player:
		controlling_player.add_planet(self)
		if controlling_player.level:
			controlling_player.level.check_victory()

	_reset_capture()

# ----------------- Visual -----------------
func update_color():
	var c := Color(0.75, 0.75, 0.75) # default gray

	if controlling_player:
		c = controlling_player.color
		if is_selected:
			c = c.lightened(0.2)

	button.modulate = c

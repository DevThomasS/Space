class_name Ship extends Node2D

enum State { ORBITING, TRAVELING }

@onready var sprite := $Sprite2D

var state := State.ORBITING
var from_planet: Planet
var to_planet: Planet
var controlling_player: BasePlayer

@export var travel_speed := 200.0
var t := 0.0

func _ready():
	z_index = 0
	if controlling_player:
		sprite.modulate = controlling_player.color

func _process(delta):
	if state != State.TRAVELING or not from_planet or not to_planet:
		return

	t += delta * travel_speed / from_planet.global_position.distance_to(to_planet.global_position)
	global_position = from_planet.global_position.lerp(to_planet.global_position, t)

	if t >= 1.0:
		arrive()

func arrive():
	state = State.ORBITING
	if get_parent():
		get_parent().remove_child(self)
	to_planet.receive_ship(self)

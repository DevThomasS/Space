class_name Ship extends Node2D

enum State { ORBITING, TRAVELING }

var state: State = State.ORBITING
var from_planet: Node2D
var to_planet: Node2D

var travel_speed := 200.0
var t := 0.0

func _process(delta):
	if state != State.TRAVELING or not from_planet or not to_planet:
		return

	t += delta * travel_speed / from_planet.position.distance_to(to_planet.position)
	global_position = from_planet.global_position.lerp(
		to_planet.global_position,
		t
	)
	if t >= 1.0:
		arrive()

func _ready():
	z_index = 0

func arrive():
	to_planet.receive_ship()
	queue_free()

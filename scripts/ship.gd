class_name Ship extends Node2D

enum State { ORBITING, TRAVELING }

var state: State = State.ORBITING
var from_planet: Node2D
var to_planet: Node2D

var orbit_radius := 40.0
var orbit_speed := 1.0
var angle := 0.0

var travel_speed := 200.0
var t := 0.0

func _process(delta):
	match state:
		State.ORBITING:
			angle += orbit_speed * delta
			position = Vector2(cos(angle), sin(angle)) * orbit_radius

		State.TRAVELING:
			if not from_planet or not to_planet:
				return

			t += delta * travel_speed / from_planet.position.distance_to(to_planet.position)
			global_position = from_planet.global_position.lerp(
				to_planet.global_position,
				t
			)

			if t >= 1.0:
				arrive()

func arrive():
	to_planet.receive_ship()
	queue_free()

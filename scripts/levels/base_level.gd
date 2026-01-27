class_name BaseLevel extends Node2D

@onready var fleets := $Fleets

var send_fraction := 0.5
var players: Array[BasePlayer] = []

func check_victory():
	for player in players:
		if player is Blinky and player.planets.size() > 0:
			return
	print("Victory!")

func send_ships(from: Planet, to: Planet):
	if not from or not to or from.controlling_player == null:
		return
	var orbit := from.orbit
	var total := orbit.count()
	if total == 0:
		return
	var to_send := int(total * send_fraction)
	to_send = max(to_send, 1)
	for i in range(to_send):
		try_send_ship(orbit, from, to)

func try_send_ship(orbit: Orbit, from: Planet, to: Planet):
	if orbit.count() == 0:
		return
	var ship := orbit.ships[0]
	from.remove_orbit_ship(ship)
	ship.state = ship.State.TRAVELING
	ship.from_planet = from
	ship.to_planet = to
	ship.controlling_player = from.controlling_player
	ship.global_position = from.global_position
	ship.t = 0.0
	fleets.add_child(ship)

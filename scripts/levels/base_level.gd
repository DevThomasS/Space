class_name BaseLevel extends Node2D

@onready var fleets := $Fleets

var send_fraction := 0.5
var players: Array[BasePlayer] = []
var selected_planet: Planet = null
var victory_triggered := false
var initializing := true

func check_victory():
	if victory_triggered or initializing:
		return
	var ai_has_planets := false
	for player in players:
		if player is Blinky and player.my_planets.size() > 0:
			ai_has_planets = true
			break
	if ai_has_planets:
		return
	var human_has_planets := false
	for player in players:
		if player is Human and player.my_planets.size() > 0:
			human_has_planets = true
			break
	if not human_has_planets:
		return
	victory_triggered = true
	print("Victory!")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")

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
	orbit.remove_ship(ship)
	ship.state = ship.State.TRAVELING
	ship.from_planet = from
	ship.to_planet = to
	ship.controlling_player = from.controlling_player
	ship.global_position = from.global_position
	ship.t = 0.0
	fleets.add_child(ship)

func planet_clicked(clicked: Planet):
	if selected_planet:
		# Only send ships if they are different planets
		if selected_planet != clicked:
			# Use the controlling player's level to send ships
			if selected_planet.controlling_player:
				selected_planet.controlling_player.level.send_ships(selected_planet, clicked)
		selected_planet = null
		return
	# No planet selected yet, select if human
	if clicked.controlling_player and clicked.controlling_player is Human:
		selected_planet = clicked

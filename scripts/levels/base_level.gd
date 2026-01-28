class_name BaseLevel extends Node2D

@onready var fleets := $Fleets

var send_fraction := 0.5
var players: Array[BasePlayer] = []
var selected_planet: BasePlanet = null
var victory_triggered := false
var initializing := true

func check_victory():
	if victory_triggered or initializing:
		return
	var ai_has_planets := false
	for player in players:
		if player is BlinkyAI and player.my_planets.size() > 0:
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
	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")

func send_ships(from: BasePlanet, to: BasePlanet, player: BasePlayer = null):
	if not from or not to:
		return
	var sender := player if player != null else from.controlling_player
	if sender == null:
		return
	var orbit := from.orbit
	var total := orbit.get_ships_for_player(sender)
	if total == 0:
		return
	var to_send := int(total * send_fraction)
	to_send = max(to_send, 1)
	for i in range(to_send):
		try_send_ship(orbit, from, to)

func try_send_ship(orbit: Orbit, from: BasePlanet, to: BasePlanet):
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

func planet_clicked(clicked: BasePlanet):
	var human_player = null
	# If a planet is already selected, attempt to send ships
	if selected_planet:
		if selected_planet != clicked:
			# Ensure selected planet is valid to send from (controlled or has human ships)
			for p in players:
				if p is Human:
					human_player = p
					break
			if human_player:
				var ships_available = selected_planet.orbit.get_ships_for_player(human_player)
				if selected_planet.controlling_player == human_player or ships_available > 0:
					human_player.level.send_ships(selected_planet, clicked)
		selected_planet = null
		return

	# No planet selected yet, select if human-controlled or has human ships in orbit
	for p in players:
		if p is Human:
			human_player = p
			break
	if human_player:
		var ships_available = clicked.orbit.get_ships_for_player(human_player)
		if clicked.controlling_player == human_player or ships_available > 0:
			selected_planet = clicked

class_name BaseLevel extends Node2D

@onready var fleets := $Fleets
@onready var queries := PlanetQuery.new()

var send_fraction := 0.5
var players: Array[BasePlayer] = []
var selected_planet: BasePlanet = null
var victory_triggered := false
var initializing := true

func _ready():
	queries.setup(get_tree())
	# Auto-collect all players in the scene
	for p in get_tree().get_nodes_in_group("players"):
		p.level = self
		# Provide planet query to AI players
		if p is BaseAI:
			p.queries = queries
		# Assign starting planets from Player node
		for planet_node in p.starting_planets:
			if planet_node:
				p.add_planet(planet_node)
		players.append(p)
	# Auto-collect all planets in the scene
	for planet in get_tree().get_nodes_in_group("planets"):
		if planet.button:
			planet.button.pressed.connect(Callable(self, "planet_clicked").bind(planet))
	initializing = false

func check_victory():
	VictoryChecker.check(self)

func on_victory():
	victory_triggered = true
	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")

func send_ships(from: BasePlanet, to: BasePlanet, player: BasePlayer = null):
	FleetManager.send_ships(self, from, to, send_fraction, player)

func planet_clicked(clicked: BasePlanet):
	selected_planet = ClickHelper.handle_click(self, clicked)

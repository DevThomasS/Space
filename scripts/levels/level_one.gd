class_name LevelOne extends BaseLevel

@export var human_start_planet: Planet
@export var blinky_start_planet: Planet

@onready var queries := PlanetQuery.new()
@onready var human := Human.new()
@onready var blinky := Blinky.new()

var selected_planet: Planet = null

func _ready():
	# Reset all planets
	for planet in get_tree().get_nodes_in_group("planets"):
		if planet:
			planet.set_controlling_player(null)
	add_child(queries)
	# Assign human player
	human.level = self
	if human_start_planet:
		human.add_planet(human_start_planet)
	add_child(human)
	# Assign Blinky AI
	blinky.level = self
	blinky.queries = queries
	if blinky_start_planet:
		blinky.add_planet(blinky_start_planet)
	add_child(blinky)

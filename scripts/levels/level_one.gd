class_name LevelOne extends BaseLevel

@export var human_start_planet: SmallPlanet
@export var blinky_start_planet: SmallPlanet

@onready var queries := PlanetQuery.new()
@onready var human := Human.new()
@onready var blinky := Blinky.new()

func _ready():
	queries.setup(get_tree())
	# Assign human player
	human.level = self
	if human_start_planet:
		human.add_planet(human_start_planet)
	players.append(human)
	add_child(human)
	# Assign Blinky AI
	blinky.level = self
	blinky.queries = queries
	if blinky_start_planet:
		blinky.add_planet(blinky_start_planet)
	players.append(blinky)
	add_child(blinky)
	# Connect each planet's button to level's planet_clicked()
	for planet in get_tree().get_nodes_in_group("planets"):
		if planet.button:
			planet.button.pressed.connect(Callable(self, "planet_clicked").bind(planet))
	initializing = false

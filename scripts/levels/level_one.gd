class_name LevelOne extends BaseLevel

@onready var queries := PlanetQuery.new()
@onready var blinky := Blinky.new()

var selected_planet: Planet = null

func _ready():
	add_child(queries)
	blinky.level = self
	blinky.queries = queries
	add_child(blinky)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var clicked := get_planet_at_mouse()
		if clicked:
			handle_planet_click(clicked)

func handle_planet_click(planet: Planet):
	if selected_planet == null and planet.faction == Planet.Faction.PLAYER:
		selected_planet = planet
		return
	if planet == selected_planet:
		selected_planet = null
		return
	send_ships(selected_planet, planet)
	selected_planet = null

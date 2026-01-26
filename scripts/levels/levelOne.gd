class_name LevelOne extends Node2D

@onready var fleets := $Fleets
@onready var queries := PlanetQuery.new()
@onready var blinky := Blinky.new()

var selectedPlanet: Planet = null
var sendFraction := 0.5

func _ready():
	add_child(queries)
	blinky.levelOne = self
	blinky.queries = queries
	add_child(blinky)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var clicked := get_planet_at_mouse()
		if clicked:
			handle_planet_click(clicked)

func handle_planet_click(planet: Planet):
	if selectedPlanet == null and planet.faction == Planet.Faction.PLAYER:
		selectedPlanet = planet
		return
	if planet == selectedPlanet:
		selectedPlanet = null
		return
	send_ships(selectedPlanet, planet)
	selectedPlanet = null

func send_ships(from: Planet, to: Planet):
	if not from or not to:
		return
	var orbit := from.orbit
	var total := orbit.count()
	if total == 0:
		return
	var to_send := int(total * sendFraction)
	to_send = max(to_send, 1)
	for i in range(to_send):
		if orbit.count() == 0:
			break
		var ship := orbit.ships[0]
		from.remove_orbit_ship(ship)
		ship.state = ship.State.TRAVELING
		ship.from_planet = from
		ship.to_planet = to
		ship.global_position = from.global_position
		ship.t = 0.0
		fleets.add_child(ship)

func get_planet_at_mouse() -> Planet:
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	var result := space.intersect_point(query)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

class_name Blinky extends BasePlayer

@export var send_interval := 2.5
@export var min_ships_to_send := 10

var timer := 0.0
var level: BaseLevel
var queries: PlanetQuery

func _process(delta):
	timer += delta
	if timer >= send_interval:
		timer = 0.0
		take_turn()

func take_turn():
	var ai_planets = queries.get_by_faction(Planet.Faction.AI)
	var targets = queries.get_not_faction(Planet.Faction.AI)

	for planet in ai_planets:
		if planet.available_ships() < send_interval:
			continue

		var target := queries.get_closest_planet(planet, targets)
		if target:
			level.send_ships(planet, target)

class_name Blinky extends Node

@export var sendInterval := 2.5
@export var minShipsToSend := 10

var timer := 0.0
var levelOne: LevelOne
var queries: PlanetQuery

func _process(delta):
	timer += delta
	if timer >= sendInterval:
		timer = 0.0
		take_turn()

func take_turn():
	var aiPlanets = queries.get_by_faction(Planet.Faction.AI)
	var targets = queries.get_not_faction(Planet.Faction.AI)

	for planet in aiPlanets:
		if planet.availableShips() < minShipsToSend:
			continue

		var target := queries.get_closest_planet(planet, targets)
		if target:
			levelOne.send_ships(planet, target)

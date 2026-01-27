class_name BasePlayer extends Node

var max_population := 0
var current_population := 0
var my_planets: Array[Planet] = []
var color: Color = Color.GRAY
var queries: PlanetQuery
var level: BaseLevel

func add_planet(planet: Planet):
	if planet == null:
		push_error("Cannot add null planet")
		return
	if planet.controlling_player and planet.controlling_player != self:
		planet.controlling_player.remove_planet(planet)
	if planet not in my_planets:
		my_planets.append(planet)
		planet.set_controlling_player(self)

func remove_planet(planet: Planet):
	my_planets.erase(planet)

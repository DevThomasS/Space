class_name BasePlayer extends Node

var max_population := 0
var current_population := 0
var my_planets: Array[Planet] = []
var color: Color = Color.GRAY
var queries: PlanetQuery
var level: BaseLevel

# BasePlayer never changes ownership.
# Planet.set_controlling_player() is the single authority.
func add_planet(planet: Planet):
	if planet.controlling_player and planet.controlling_player != self:
		planet.controlling_player.remove_planet(planet)
	if planet not in my_planets:
		my_planets.append(planet)
		planet.set_controlling_player(self)

func remove_planet(planet: Planet):
	my_planets.erase(planet)

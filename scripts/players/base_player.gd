class_name BasePlayer extends Node

@export var data: PlayerData

var color: Color = Color.GRAY
var my_planets: Array[BasePlanet] = []
var queries: PlanetQuery
var level: BaseLevel
var max_population := 0 # TODO: Implement
var current_population := 0 # TODO: Implement

# BasePlayer never changes ownership.
# Planet.set_controlling_player() is the single authority.
func add_planet(planet: BasePlanet):
	if planet.controlling_player and planet.controlling_player != self:
		planet.controlling_player.remove_planet(planet)
	if planet not in my_planets:
		my_planets.append(planet)
		planet.set_controlling_player(self)

func remove_planet(planet: BasePlanet):
	my_planets.erase(planet)

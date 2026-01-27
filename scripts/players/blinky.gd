class_name Blinky extends BasePlayer

@export var send_interval := 2.5
@export var min_ships_to_send := 10

var timer := 0.0

func _ready():
	color = Color.INDIAN_RED

func _process(delta):
	timer += delta
	if timer >= send_interval:
		timer = 0.0
		take_turn()

func take_turn():
	if queries == null or my_planets == []:
		return
	var targets = queries.get_not_player(self)
	for planet in my_planets:
		if planet.controlling_player != self or planet.orbit.count() < min_ships_to_send:
			continue
		if planet.orbit.is_in_combat():
			var my_ships = planet.orbit.get_ships_for_player(self)
			var enemy_ships = planet.orbit.count() - my_ships
			if my_ships < enemy_ships:
				# Do NOT send ships, it'll likely lose the fight
				continue
		var target := queries.get_closest_planet(planet, targets)
		if target:
			level.send_ships(planet, target, self)

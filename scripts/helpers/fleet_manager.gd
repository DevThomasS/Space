class_name FleetManager extends Node

static func send_ships(level: Node, from: BasePlanet, to: BasePlanet, fraction: float = 0.5, player: BasePlayer = null):
	if not from or not to:
		return
	var sender := player if player != null else from.controlling_player
	if sender == null:
		return
	
	var orbit := from.orbit
	var total := orbit.get_ships_for_player(sender)
	if total == 0:
		return
	
	var to_send := int(total * fraction)
	to_send = max(to_send, 1)
	for i in range(to_send):
		FleetManager.try_send_ship(level, orbit, from, to)

static func try_send_ship(level: Node, orbit: Orbit, from: BasePlanet, to: BasePlanet):
	if orbit.count() == 0:
		return
	var ship := orbit.ships[0]
	orbit.remove_ship(ship)
	ship.state = ship.State.TRAVELING
	ship.from_planet = from
	ship.to_planet = to
	ship.controlling_player = from.controlling_player
	ship.global_position = from.global_position
	ship.t = 0.0
	level.fleets.add_child(ship)

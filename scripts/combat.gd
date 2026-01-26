class_name Combat

static func resolve_attack(defenders: int, attackers: int) -> Dictionary:
	var remaining = defenders - attackers
	if remaining >= 0:
		return { "defenders": remaining, "captured": false }
	return { "defenders": abs(remaining), "captured": true }

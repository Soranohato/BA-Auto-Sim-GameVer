class_name CombatSystem
extends RefCounted

# Logic for students picking targets.
# Random: chooses a random target per attack
# nearest: chooses the nearest target to student
static func pick_target(attacker: Character, enemies: Array[Character], strategy: String) -> Character:
	var living: Array[Character] = enemies.filter(func(e): return e.is_alive())

	if strategy == "random":
		return living[randi() % living.size()]

	if strategy == "nearest":
		var nearest: Character = living[0]
		var nearest_dist: float = attacker.pos.distance_to(nearest.pos)
		for e in living:
			var d: float = attacker.pos.distance_to(e.pos)
			if d < nearest_dist:
				nearest_dist = d
				nearest = e
		return nearest

	push_error("CombatSystem: unknown target strategy: %s" % strategy)
	return null

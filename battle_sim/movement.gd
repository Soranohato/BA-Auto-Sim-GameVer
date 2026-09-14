# Movement: advancing a character's float position toward a target at a
# fixed speed, and checking whether an attacker is currently in range.

class_name Movement
extends RefCounted

const ARRIVAL_EPSILON := 0.05

static func is_in_range(attacker: Character, defender: Character) -> bool:
	return attacker.pos.distance_to(defender.pos) <= attacker.atk_range

# Returns a Vector2, or null if nothing qualifies
# A cover object qualifies if:
#   - it isnt destroyed
#   - being in it would put the defender within character.atk_range
#   - no other living character is already occupying it (within COVER_RADIUS)
# Picks closest qualifying cover
static func _find_best_cover_position(character: Character, defender: Character,
		cover_objects: Array[CoverObject], all_units: Array[Character]) -> Variant:
	var best: CoverObject = null
	var best_dist := INF

	for cover in cover_objects:
		if cover.is_destroyed():
			continue
		if cover.pos.distance_to(defender.pos) > character.atk_range:
			continue  # would put defender out of range

		var occupied := false
		for other in all_units:
			if other != character and other.is_alive() and other.pos.distance_to(cover.pos) <= CoverSystem.COVER_RADIUS:
				occupied = true
				break
		if occupied:
			continue

		var d := character.pos.distance_to(cover.pos)
		if d < best_dist:
			best_dist = d
			best = cover

	if best == null:
		return null
	return best.pos

# Advance character.pos by up to MOVE_SPEED this tick.
# Prefers heading to a qualifying, unoccupied cover object that would put
# defender in range once reached. Falls back to moving straight at
# defender.pos if no such cover exists. Updates isMoving based on
# whether the character has arrived at its destination this tick.
static func move_toward(character: Character, defender: Character,
		cover_objects: Array[CoverObject], all_units: Array[Character]) -> void:
	var target_pos: Variant = _find_best_cover_position(character, defender, cover_objects, all_units)
	if target_pos == null:
		target_pos = defender.pos

	var delta: Vector2 = target_pos - character.pos
	var dist := delta.length()

	if dist <= ARRIVAL_EPSILON:
		character.pos = target_pos
		character.is_moving = false
		return

	var step := minf(GridConfig.MOVE_SPEED, dist)
	character.pos += delta.normalized() * step
	character.is_moving = (dist - step) > ARRIVAL_EPSILON

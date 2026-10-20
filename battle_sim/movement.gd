# Movement: advancing a character's float position toward a target at a
# fixed speed, and checking whether an attacker is currently in range.

class_name Movement
extends RefCounted

const ARRIVAL_EPSILON := 0.05

static func is_in_range(attacker: Character, defender: Character) -> bool:
	return attacker.pos.distance_to(defender.pos) <= attacker.atk_range

static func _grid_bounds() -> Rect2:
	var r := GridConfig.UNIT_RADIUS
	return Rect2(Vector2(r, r),
		Vector2(GridConfig.GRID_WIDTH - 2.0 * r, GridConfig.GRID_HEIGHT - 2.0 * r))

static func _obstacle_centers(cover_objects: Array[CoverObject]) -> Array[Vector2]:
	var centers: Array[Vector2] = []
	for cover in cover_objects:
		if not cover.is_destroyed():
			centers.append(cover.pos)
	return centers

static func _is_claimed(cover: CoverObject, character: Character,
		all_units: Array[Character]) -> bool:
	for other in all_units:
		if other != character and other.is_alive() and other.cover_target == cover:
			return true
	return false

# The spot behind `cover` (relative to `defender`) this character could stand at,
# or null if the cover can't be used. Unusable if:
#   - destroyed, or claimed by another living unit
#   - the spot is off the grid, or can't reach the defender (atk_range)
#   - the spot would overlap another cover, or another unit's body
static func _usable_stand_pos(character: Character, defender: Character, cover: CoverObject,
		cover_objects: Array[CoverObject], all_units: Array[Character]) -> Variant:
	if cover.is_destroyed() or _is_claimed(cover, character, all_units):
		return null

	var stand := CoverSystem.get_stand_pos(cover, defender.pos)
	if not _grid_bounds().has_point(stand):
		return null
	if stand.distance_to(defender.pos) > character.atk_range:
		return null

	for other_cover in cover_objects:
		if other_cover == cover or other_cover.is_destroyed():
			continue
		if Pathing.dist_to_square(stand, other_cover.pos, CoverSystem.COVER_RADIUS) < GridConfig.UNIT_RADIUS:
			return null

	for other in all_units:
		if other != character and other.is_alive() \
				and other.pos.distance_to(stand) < GridConfig.UNIT_RADIUS * 2.0:
			return null
	return stand

# Claims the closest usable cover (by straight-line distance to its stand spot),
# or clears the claim if nothing qualifies
static func _choose_cover(character: Character, defender: Character,
		cover_objects: Array[CoverObject], all_units: Array[Character]) -> void:
	var best: CoverObject = null
	var best_stand := Vector2.ZERO
	var best_dist := INF
	for cover in cover_objects:
		var stand: Variant = _usable_stand_pos(character, defender, cover, cover_objects, all_units)
		if stand == null:
			continue
		var d := character.pos.distance_to(stand)
		if d < best_dist:
			best_dist = d
			best = cover
			best_stand = stand
	character.cover_target = best
	character.stand_pos = best_stand

# A claim stays valid until the cover is destroyed, someone else holds it, or
# its stand spot can no longer reach the current defender
static func _commitment_valid(character: Character, defender: Character,
		all_units: Array[Character]) -> bool:
	var cover := character.cover_target
	if cover == null or cover.is_destroyed():
		return false
	if _is_claimed(cover, character, all_units):
		return false
	return character.stand_pos.distance_to(defender.pos) <= character.atk_range

# Advance character.pos by up to MOVE_SPEED this tick
# Heads for the stand spot behind its claimed cover, or straight at the defender
# if it has none. Routes around all cover via Pathing. is_moving reflects whether
# the character has reached its real destination, not just the next waypoint
static func move_toward(character: Character, defender: Character,
		cover_objects: Array[CoverObject], all_units: Array[Character]) -> void:
	if not _commitment_valid(character, defender, all_units):
		_choose_cover(character, defender, cover_objects, all_units)

	var dest: Vector2 = defender.pos if character.cover_target == null else character.stand_pos

	if character.pos.distance_to(dest) <= ARRIVAL_EPSILON:
		character.pos = dest
		character.is_moving = false
		return

	var waypoint := Pathing.next_waypoint(character.pos, dest,
			_obstacle_centers(cover_objects),
			CoverSystem.COVER_RADIUS, GridConfig.UNIT_RADIUS, _grid_bounds())
	var delta := waypoint - character.pos
	var dist := delta.length()
	if dist > 0.0:
		var step := minf(GridConfig.MOVE_SPEED * BattleState.TICK_DURATION, dist)
		character.pos += delta / dist * step
	character.is_moving = character.pos.distance_to(dest) > ARRIVAL_EPSILON

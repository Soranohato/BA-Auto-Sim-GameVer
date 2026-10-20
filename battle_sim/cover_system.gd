# System for managing cover, if a student is within range or not as well
# as how close they are to cover

class_name CoverSystem
extends RefCounted

const COVER_DAMAGE_REDUCTION := 0.3
const COVER_RADIUS := 0.5 # half-side of the square cover (also "in cover" range)
const COVER_Y_MARGIN := 0.5
const MIN_COVER_SPACING := 1.5
const MAX_PLACEMENT_ATTEMPTS := 20

# Side cover is rolled for team A inside [COVER_X_MIN, COVER_X_MAX] then team B is mirrored
# Spawn columns are back x=2 / front x=8, center cover sits at x=10
const COVER_X_MIN := 4.0
const COVER_X_MAX := 6.5

const STAND_GAP := 0.05                 # clearance between a unit's circle and its cover
const COVER_ADJACENT_TOLERANCE := 0.1   # slack for "this unit is at that cover"
const COVER_LINE_TOLERANCE := 0.05      # slack for "the shot line crosses that cover"

static var CENTER_X: float = GridConfig.GRID_WIDTH / 2.0
static var CENTER_Y: float = GridConfig.GRID_HEIGHT / 2.0
# Keeps each top/bottom mirrored pair at least MIN_COVER_SPACING apart
static var COVER_Y_MAX: float = CENTER_Y - MIN_COVER_SPACING / 2.0

static func _dist_to_cover(p: Vector2, cover: CoverObject) -> float:
	return Pathing.dist_to_square(p, cover.pos, COVER_RADIUS)

static func _far_enough(x: float, y: float, placed: Array[CoverObject]) -> bool:
	for c in placed:
		if Vector2(x, y).distance_to(c.pos) < MIN_COVER_SPACING:
			return false
	return true

# seed = -1 means "no explicit seed".
# handles random cover placement
static func make_cover_layout(n_per_side: int, include_center: bool, seed: int = -1) -> Array[CoverObject]:
	assert(n_per_side % 2 == 0, "n_per_side must be even")

	var rng := RandomNumberGenerator.new()
	if seed >= 0:
		rng.seed = seed
	else:
		rng.randomize()

	var cover_objects: Array[CoverObject] = []
	var rolls_needed := n_per_side / 2
	var counter := 0

	for _i in range(rolls_needed):
		var x := 0.0
		var y := 0.0
		var mirror_y := 0.0
		var placed := false
		for _attempt in range(MAX_PLACEMENT_ATTEMPTS):
			x = rng.randf_range(COVER_X_MIN, COVER_X_MAX)
			y = rng.randf_range(COVER_Y_MARGIN, COVER_Y_MAX)
			mirror_y = GridConfig.GRID_HEIGHT - y
			if _far_enough(x, y, cover_objects) and _far_enough(x, mirror_y, cover_objects):
				placed = true
				break
		if not placed:
			push_error("CoverSystem: no valid spot after %d attempts, placing last roll anyway" % MAX_PLACEMENT_ATTEMPTS)

		var mirror_x := GridConfig.GRID_WIDTH - x
		counter += 1
		cover_objects.append(CoverObject.new("Cover%dA_top" % counter, Vector2(x, y), COVER_DAMAGE_REDUCTION, 25000))
		cover_objects.append(CoverObject.new("Cover%dA_bot" % counter, Vector2(x, mirror_y), COVER_DAMAGE_REDUCTION, 25000))
		cover_objects.append(CoverObject.new("Cover%dB_top" % counter, Vector2(mirror_x, y), COVER_DAMAGE_REDUCTION, 25000))
		cover_objects.append(CoverObject.new("Cover%dB_bot" % counter, Vector2(mirror_x, mirror_y), COVER_DAMAGE_REDUCTION, 25000))

	if include_center:
		cover_objects.append(CoverObject.new("CoverMid", Vector2(CENTER_X, CENTER_Y), COVER_DAMAGE_REDUCTION, 50000))

	return cover_objects
	
static func get_stand_pos(cover: CoverObject, enemy_pos: Vector2) -> Vector2:
	var dir := cover.pos - enemy_pos
	if dir.length_squared() < 0.000001:
		dir = Vector2.RIGHT  # enemy exactly on the cover, any side will do
	dir = dir.normalized()

	var clearance := GridConfig.UNIT_RADIUS + STAND_GAP
	var lo := 0.0
	var hi := 3.0
	for _i in range(24):
		var mid := (lo + hi) / 2.0
		if _dist_to_cover(cover.pos + dir * mid, cover) < clearance:
			lo = mid
		else:
			hi = mid
	return cover.pos + dir * hi

# determines if a Character is behind cover or not. To be behind cover a Character must be
# within COVER_RADIUS of the coer object
static func find_cover_object(defender: Character, attacker: Character,
		cover_objects: Array[CoverObject]) -> CoverObject:
	if defender.is_moving:
		return null

	var max_gap := GridConfig.UNIT_RADIUS + STAND_GAP + COVER_ADJACENT_TOLERANCE
	var best: CoverObject = null
	var best_dist := INF
	for cover in cover_objects:
		if cover.is_destroyed():
			continue
		var d := _dist_to_cover(defender.pos, cover)
		if d > max_gap or d >= best_dist:
			continue
		if Pathing.segment_hits_square(attacker.pos, defender.pos, cover.pos,
				COVER_RADIUS + COVER_LINE_TOLERANCE):
			best = cover
			best_dist = d
	return best

static func get_cover_reduction(defender: Character, attacker: Character,
		cover_objects: Array[CoverObject]) -> Array:
	var provider := find_cover_object(defender, attacker, cover_objects)
	if provider == null:
		return [0.0, null]
	return [provider.reduction, provider]

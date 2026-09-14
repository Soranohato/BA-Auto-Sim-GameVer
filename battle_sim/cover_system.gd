# System for managing cover, if a student is within range or not as well
# as how close they are to cover

class_name CoverSystem
extends RefCounted

const COVER_DAMAGE_REDUCTION := 0.3
const COVER_RADIUS := 0.5
const COVER_Y_MARGIN := 0.5
const MIN_COVER_SPACING := 1.5
const MAX_PLACEMENT_ATTEMPTS := 20

# Derived from GridConfig. `static var` needs Godot 4.2+ (project is 4.7, fine).
static var CENTER_X: float = GridConfig.GRID_WIDTH / 2.0
static var CENTER_Y: float = GridConfig.GRID_HEIGHT / 2.0
static var COVER_X_MIN: float = GridConfig.FRONT_X["A"]

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
		for _attempt in range(MAX_PLACEMENT_ATTEMPTS):
			x = rng.randf_range(COVER_X_MIN, CENTER_X - 0.5)
			y = rng.randf_range(COVER_Y_MARGIN, CENTER_Y - 0.5)
			mirror_y = GridConfig.GRID_HEIGHT - y
			if _far_enough(x, y, cover_objects) and _far_enough(x, mirror_y, cover_objects):
				break

		var mirror_x := GridConfig.GRID_WIDTH - x
		counter += 1
		cover_objects.append(CoverObject.new("Cover%dA_top" % counter, Vector2(x, y), COVER_DAMAGE_REDUCTION, 25000))
		cover_objects.append(CoverObject.new("Cover%dA_bot" % counter, Vector2(x, mirror_y), COVER_DAMAGE_REDUCTION, 25000))
		cover_objects.append(CoverObject.new("Cover%dB_top" % counter, Vector2(mirror_x, y), COVER_DAMAGE_REDUCTION, 25000))
		cover_objects.append(CoverObject.new("Cover%dB_bot" % counter, Vector2(mirror_x, mirror_y), COVER_DAMAGE_REDUCTION, 25000))

	if include_center:
		cover_objects.append(CoverObject.new("CoverMid", Vector2(CENTER_X, CENTER_Y), COVER_DAMAGE_REDUCTION, 50000))

	return cover_objects

# determines if a Character is behind cover or not. To be behind cover a Character must be
# within COVER_RADIUS of the coer object
static func find_cover_object(defender: Character, cover_objects: Array[CoverObject]) -> CoverObject:
	if defender.is_moving:
		return null
	for cover in cover_objects:
		if defender.pos.distance_to(cover.pos) <= COVER_RADIUS and not cover.is_destroyed():
			return cover
	return null

static func get_cover_reduction(defender: Character, cover_objects: Array[CoverObject]) -> Array:
	var provider := find_cover_object(defender, cover_objects)
	if provider == null:
		return [0.0, null]
	return [provider.reduction, provider]

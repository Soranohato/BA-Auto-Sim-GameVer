#Grid layout and positioning.

class_name GridConfig
extends RefCounted

# Sim space in GRID UNITS
const GRID_WIDTH := 20.0
const GRID_HEIGHT := 10.0
const FRONT_X := {"A": 8.0, "B": 12.0}
const BACK_X := {"A": 2.0, "B": 18.0}
const FRONT_ROLES := ["tank", "striker"]
const MOVE_SPEED := 1.0

# Screen space in PIXELS -- this is used by the visual layer and only via the 
# 3 functions below
const DESIGN_SIZE := Vector2(1920.0, 1080.0) # needs to match viewport
const CELL_SIZE := 96.0 # GRID_WIDTH x VIEWPORT_WIDTH
const GRID_ORIGIN := Vector2(0.0, (1080.0 - GRID_HEIGHT * CELL_SIZE) / 2.0)

# grid postion -> screen position
static func to_screen(p: Vector2) -> Vector2:
	return GRID_ORIGIN + p * CELL_SIZE
	
# screen position -> grid position
static func to_grid(screen_p: Vector2) -> Vector2:
	return (screen_p - GRID_ORIGIN) / CELL_SIZE
	
# grid unit length -> pixel length
static func px(grid_units: float) -> float:
	return grid_units * CELL_SIZE

# actual grid function
static func assign_positions(team: Array[Character], side: String) -> void:
	var rows := [2.0, 5.0, 8.0]
	var y_front := 0
	var y_back := 0
	for c in team:
		c.side = side
		if FRONT_ROLES.has(c.role):
			c.pos = Vector2(FRONT_X[side], rows[y_front % rows.size()])
			y_front += 1
		else:
			c.pos = Vector2(BACK_X[side], rows[y_back % rows.size()])
			y_back += 1

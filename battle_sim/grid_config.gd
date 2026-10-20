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
const UNIT_RADIUS := 0.3

# Screen space in PIXELS -- this is used by the visual layer and only via the 
# 3 functions below
const DESIGN_SIZE := Vector2(1920.0, 1080.0) # needs to match viewport

#HUD regions
const SIDE_PANEL_WIDTH := 240.0
const TOP_BAR_HEIGHT := 120.0

# grid sized to fit between side panels
const CELL_SIZE := (1920.0 - 2.0 * SIDE_PANEL_WIDTH) / GRID_WIDTH

# grid sits between side panels and centered vertically below top bar
const GRID_ORIGIN := Vector2(
	SIDE_PANEL_WIDTH, TOP_BAR_HEIGHT + (1080.0 - TOP_BAR_HEIGHT - GRID_HEIGHT * CELL_SIZE) / 2.0)

# grid postion -> screen position
static func to_screen(p: Vector2) -> Vector2:
	return GRID_ORIGIN + p * CELL_SIZE
	
# screen position -> grid position
static func to_grid(screen_p: Vector2) -> Vector2:
	return (screen_p - GRID_ORIGIN) / CELL_SIZE
	
# grid unit length -> pixel length
static func px(grid_units: float) -> float:
	return grid_units * CELL_SIZE
	
# HUD in screen pixels
static func top_bar_rect() -> Rect2:
	return Rect2(0.0, 0.0, DESIGN_SIZE.x, TOP_BAR_HEIGHT)

static func left_panel_rect() -> Rect2:
	return Rect2(0.0, TOP_BAR_HEIGHT, SIDE_PANEL_WIDTH, DESIGN_SIZE.y - TOP_BAR_HEIGHT)

static func right_panel_rect() -> Rect2:
	return Rect2(DESIGN_SIZE.x - SIDE_PANEL_WIDTH, TOP_BAR_HEIGHT,
		SIDE_PANEL_WIDTH, DESIGN_SIZE.y - TOP_BAR_HEIGHT)

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

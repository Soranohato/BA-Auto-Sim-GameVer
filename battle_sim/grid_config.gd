#Grid layout and positioning.

class_name GridConfig
extends RefCounted

const GRID_WIDTH := 20.0
const GRID_HEIGHT := 10.0
const FRONT_X := {"A": 8.0, "B": 12.0}
const BACK_X := {"A": 2.0, "B": 18.0}
const FRONT_ROLES := ["tank", "striker"]
const MOVE_SPEED := 1.0

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

class_name CharacterView
extends Node2D

const COLOR_A := Color(0.3, 0.6, 1.0)
const COLOR_B := Color(1.0, 0.4, 0.4)
const RADIUS_UNITS := 0.3  # in GRID units, not pixels (see _draw)

var character: Character

func setup(c: Character) -> void:
	character = c
	position = BattleView.grid_to_screen(character.pos)

func _process(_delta: float) -> void:
	position = BattleView.grid_to_screen(character.pos)
	queue_redraw()

func _draw() -> void:
	var colorUse
	if character.side == "A":
		colorUse = COLOR_A
	else:
		colorUse = COLOR_B
	var radius = RADIUS_UNITS * BattleView.cell_size
	
	draw_circle(Vector2.ZERO, radius, colorUse)

class_name CharacterView
extends Node2D

const COLOR_A := Color(0.3, 0.6, 1.0)
const COLOR_B := Color(1.0, 0.4, 0.4)

# all sizes in GRID UNITS
const RADIUS_UNITS := GridConfig.UNIT_RADIUS
const HP_BAR_WIDTH_UNITS := 1.0
const HP_BAR_HEIGHT_UNITS := 0.12
const HP_BAR_GAP_UNITS := 0.08
const LABEL_WIDTH_UNITS := 2.0
const LABEL_GAP_UNITS := 0.04

# font size in pixels
const NAME_FONT_SIZE := 20

var character: Character

func setup(c: Character) -> void:
	character = c
	position = GridConfig.to_screen(character.pos)

func _process(_delta: float) -> void:
	position = GridConfig.to_screen(character.pos)
	queue_redraw()

func _draw() -> void:
	# unit
	var color_use := COLOR_A if character.side == "A" else COLOR_B
	var radius := GridConfig.px(RADIUS_UNITS)
	draw_circle(Vector2.ZERO, radius, color_use)

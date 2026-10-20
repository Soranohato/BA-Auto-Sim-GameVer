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
var name_label: Label

func setup(c: Character) -> void:
	character = c
	position = GridConfig.to_screen(character.pos)
	_build_labels()
	
func _build_labels() -> void:
	name_label = _make_label()
	name_label.text = character.char_name
	add_child(name_label)

	var width := GridConfig.px(LABEL_WIDTH_UNITS)
	name_label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
	name_label.size.x = width
	name_label.size.y = name_label.get_minimum_size().y
	name_label.position = Vector2(
		-width / 2.0,
		-GridConfig.px(RADIUS_UNITS * 2.0 + LABEL_GAP_UNITS))
	
func _make_label() -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)  # keeps text readable over the grid
	return label

func _process(_delta: float) -> void:
	position = GridConfig.to_screen(character.pos)
	# Fade everything when downed.
	name_label.modulate.a = 1.0 if character.is_alive() else 0.35
	queue_redraw()

func _draw() -> void:
	# unit
	var color_use := COLOR_A if character.side == "A" else COLOR_B
	var radius := GridConfig.px(RADIUS_UNITS)
	draw_circle(Vector2.ZERO, radius, color_use)

	# HP bar
	var bar_w := GridConfig.px(HP_BAR_WIDTH_UNITS)
	var bar_h := GridConfig.px(HP_BAR_HEIGHT_UNITS)
	var bar_pos := Vector2(-bar_w / 2.0, radius + GridConfig.px(HP_BAR_GAP_UNITS))
	var frac := float(character.hp) / float(character.max_hp)
	draw_rect(Rect2(bar_pos, Vector2(bar_w, bar_h)), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(bar_pos, Vector2(bar_w * frac, bar_h)), Color.LIME_GREEN)

class_name CharacterView
extends Node2D

const COLOR_A := Color(0.3, 0.6, 1.0)
const COLOR_B := Color(1.0, 0.4, 0.4)
const RADIUS_UNITS := 0.3  # in GRID units, not pixels (see _draw)

const LABEL_OFFSET_Y := -0.6
const HP_BAR_WIDTH_UNITS := 1.0
const HP_BAR_HEIGHT_PX := 6.0

var character: Character
var name_label: Label

func setup(c: Character) -> void:
	character = c
	position = BattleView.grid_to_screen(character.pos)
	_build_labels()
	_update_labels()
	
func _build_labels() -> void:
	name_label = _make_label()
	name_label.text = character.char_name
	add_child(name_label)
	
func _make_label() -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)  # keeps text readable over the grid
	return label

func _update_labels() -> void:
	var cell := BattleView.cell_size
	var font_size := maxi(8, int(cell * 0.22))
	var width := cell * 2.0
	var radius := RADIUS_UNITS * cell

	for label: Label in [name_label]:
		label.add_theme_font_size_override("font_size", font_size)
		label.size.x = width
		label.size.y = label.get_minimum_size().y

	name_label.position = Vector2(-width / 2.0, -radius * 2.0 - 2.0)

	# Fade everything when downed.
	var alpha := 1.0 if character.is_alive() else 0.35
	name_label.modulate.a = alpha

func _process(_delta: float) -> void:
	position = BattleView.grid_to_screen(character.pos)
	_update_labels()
	queue_redraw()

func _draw() -> void:
	var colorUse
	if character.side == "A":
		colorUse = COLOR_A
	else:
		colorUse = COLOR_B
	var radius = RADIUS_UNITS * BattleView.cell_size
	
	draw_circle(Vector2.ZERO, radius, colorUse)
	
	# draw hp bar
	var bar_w := HP_BAR_WIDTH_UNITS * BattleView.cell_size
	var bar_pos := Vector2(-bar_w / 2.0, radius + 4.0)
	var frac := float(character.hp) / float(character.max_hp)
	draw_rect(Rect2(bar_pos, Vector2(bar_w, HP_BAR_HEIGHT_PX)), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(bar_pos, Vector2(bar_w * frac, HP_BAR_HEIGHT_PX)), Color.LIME_GREEN)

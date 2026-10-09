class_name CharacterView
extends Node2D

const RADIUS := 14.0
const BAR_SIZE := Vector2(32, 4)
const COLOR_A := Color(0.3, 0.6, 1.0)
const COLOR_B := Color(1.0, 0.4, 0.4)

var character: Character

func setup(c: Character) -> void:
	pass  # TODO: store ref, set initial position

func _process(_delta: float) -> void:
	pass  # TODO: position = BattleView.grid_to_screen(character.pos); queue_redraw()

func _draw() -> void:
	pass  # TODO: body circle (dim if dead), HP bar, ammo bar, name label,
	# reload indicator (is_reloading), maybe faint atk_range circle

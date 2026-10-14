class_name CoverView
extends Node2D

var cover: CoverObject

func setup(c: CoverObject) -> void:
	cover = c
	position = BattleView.grid_to_screen(cover.pos)

func _process(_delta: float) -> void:
	position = BattleView.grid_to_screen(cover.pos)
	queue_redraw()

func _draw() -> void:
	var side := CoverSystem.COVER_RADIUS * 2.0 * BattleView.cell_size
	var rect := Rect2(Vector2(-side / 2.0, -side / 2.0), Vector2(side, side))

	var color := Color.DIM_GRAY if cover.is_destroyed() else Color.BLACK
	draw_rect(rect, color)

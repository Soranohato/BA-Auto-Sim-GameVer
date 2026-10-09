class_name CoverView
extends Node2D

const HALF_SIZE := 10.0

var cover: CoverObject

func setup(c: CoverObject) -> void:
	pass  # TODO: store ref, position = BattleView.grid_to_screen(c.pos)

func _process(_delta: float) -> void:
	pass  # TODO: queue_redraw() (cheap while there are only ~5 of these)

func _draw() -> void:
	pass  # TODO: square; grey out if destroyed; small HP bar when hp != null

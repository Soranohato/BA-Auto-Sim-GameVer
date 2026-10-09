# Root of the visual layer. Owns the real-time -> sim-time bridge and creates
# one child view per Character / CoverObject.

class_name BattleView
extends Node2D

const CELL_SIZE := 48.0  # px per grid unit -> 20x10 grid = 960x480
const GRID_ORIGIN := Vector2(40, 40)

var state: BattleState
var sim_speed := 1.0     # 0 = paused, 2 = double speed, etc.
var _accumulator := 0.0

static func grid_to_screen(p: Vector2) -> Vector2:
	return GRID_ORIGIN + p * CELL_SIZE

func setup(state_in: BattleState) -> void:
	pass  # TODO: store state, spawn views, connect signals (battle_finished -> _on_finished)

func _spawn_views() -> void:
	pass  # TODO: CharacterView per unit (team colour by u.side), CoverView per cover

func _process(delta: float) -> void:
	pass  # TODO: _accumulator += delta * sim_speed; while >= TICK_DURATION: state.tick()
	# (cap ticks per frame so a lag spike can't spiral)

func _draw() -> void:
	pass  # TODO: grid border, FRONT_X/BACK_X guide lines, maybe 1-unit gridlines.
	# Only runs once unless queue_redraw() is called - fine for a static grid.

func _unhandled_input(event: InputEvent) -> void:
	pass  # TODO: optional - space = pause, +/- = sim_speed

func _on_finished(winner: String) -> void:
	pass  # TODO: show result label

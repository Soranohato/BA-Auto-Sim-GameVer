# Root of the visual layer. Owns the real-time -> sim-time bridge and creates
# one child view per Character / CoverObject.

class_name BattleView
extends Node2D

static var cell_size := 48.0  # px per grid unit -> 20x10 grid = 960x480
static var grid_origin := Vector2(40, 40)
const MARGIN := 40.0

var state: BattleState
var sim_speed := 1.0     # 0 = paused, 2 = double speed, etc.
var _accumulator := 0.0

static func grid_to_screen(p: Vector2) -> Vector2:
	return grid_origin + p * cell_size
	
func setup(state_in: BattleState) -> void:
	state = state_in
	_spawn_views()
	state.battle_finished.connect(_on_finished)

func _ready() -> void:
	get_viewport().size_changed.connect(_update_layout)
	_update_layout()

func _update_layout() -> void:
	var view_size := get_viewport_rect().size
	var avail := view_size - Vector2(MARGIN, MARGIN) * 2.0
	cell_size = minf(avail.x / GridConfig.GRID_WIDTH, avail.y / GridConfig.GRID_HEIGHT)
	var grid_px := Vector2(GridConfig.GRID_WIDTH, GridConfig.GRID_HEIGHT) * cell_size
	grid_origin = (view_size - grid_px) / 2.0
	queue_redraw()

func _process(delta: float) -> void:
	pass  # TODO: _accumulator += delta * sim_speed; while >= TICK_DURATION: state.tick()

func _draw() -> void:
	var grid_px := Vector2(GridConfig.GRID_WIDTH, GridConfig.GRID_HEIGHT) * cell_size
	draw_rect(Rect2(grid_origin, grid_px), Color.WHITE, false, 2.0)

	# Faint guide lines at each side's front and back columns
	var guide_color := Color(1, 1, 1, 0.2)
	for side in ["A", "B"]:
		for x: float in [GridConfig.FRONT_X[side], GridConfig.BACK_X[side]]:
			draw_line(
				grid_to_screen(Vector2(x, 0.0)),
				grid_to_screen(Vector2(x, GridConfig.GRID_HEIGHT)),
				guide_color, 1.0)
				
func _spawn_views() -> void:
	for character: Character in state.all_units:
		var unit := CharacterView.new()
		add_child(unit)
		unit.setup(character)

func _on_finished(winner: String) -> void:
	if winner == "":
		print("Battle over: draw / timed out")
	else:
		print("Battle over: Team %s wins" % winner)

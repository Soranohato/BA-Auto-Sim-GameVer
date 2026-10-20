# Root of the visual layer. Owns the real-time -> sim-time bridge and creates
# one child view per Character / CoverObject.

class_name BattleView
extends Node2D

var state: BattleState
var sim_speed := 1.0     # 0 = paused, 2 = double speed, etc.
var _accumulator := 0.0
	
func setup(state_in: BattleState) -> void:
	state = state_in
	_spawn_views()
	state.battle_finished.connect(_on_finished)

func _process(delta: float) -> void:
	if state == null or state.is_finished:
		return
	_accumulator += delta * sim_speed
	while _accumulator >= BattleState.TICK_DURATION:
		state.tick()
		_accumulator -= BattleState.TICK_DURATION

func _draw() -> void:
	var grid_px := Vector2(GridConfig.GRID_WIDTH, GridConfig.GRID_HEIGHT) * GridConfig.CELL_SIZE
	draw_rect(Rect2(GridConfig.GRID_ORIGIN, grid_px), Color.WHITE, false, 2.0)

	# Faint guide lines at each side's front and back columns
	var guide_color := Color(1, 1, 1, 0.2)
	for side in ["A", "B"]:
		for x: float in [GridConfig.FRONT_X[side], GridConfig.BACK_X[side]]:
			draw_line(
				GridConfig.to_screen(Vector2(x, 0.0)),
				GridConfig.to_screen(Vector2(x, GridConfig.GRID_HEIGHT)),
				guide_color, 1.0)
				
func _spawn_views() -> void:
	for cover: CoverObject in state.cover_objects:
		var c := CoverView.new()
		add_child(c)
		c.setup(cover)

	for character: Character in state.all_units:
		var unit := CharacterView.new()
		add_child(unit)
		unit.setup(character)
		
	var hud := HudView.new()
	add_child(hud)
	hud.setup(state)
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			sim_speed = 0.0
		if event.pressed and event.keycode == KEY_1:
			sim_speed = 1.0
		if event.pressed and event.keycode == KEY_2:
			sim_speed = 2.0

func _on_finished(winner: String) -> void:
	if winner == "":
		print("Battle over: draw / timed out")
	else:
		print("Battle over: Team %s wins" % winner)

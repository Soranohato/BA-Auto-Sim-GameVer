# Side panels and top bar

class_name HudView
extends Node2D

const PANEL_COLOR := Color(0, 0, 0, 0.35)
const BAR_BG_COLOR := Color(0, 0, 0, 0.6)
const BAR_COLOR := Color.LIME_GREEN
const TEXT_COLOR := Color.WHITE

const PANEL_PADDING := 20.0
const ROW_HEIGHT := 56.0
const ROW_GAP := 24.0
const NAME_FONT_SIZE := 22
const BAR_HEIGHT := 14.0
const BAR_GAP := 10.0
const DOWNED_ALPHA := 0.35

var state: BattleState

func setup(state_in: BattleState) -> void:
	state = state_in

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	if state == null:
		return
	_draw_team_panel(GridConfig.left_panel_rect(), state.team_a)
	_draw_team_panel(GridConfig.right_panel_rect(), state.team_b)
	_draw_top_bar()

func _draw_team_panel(rect: Rect2, team: Array[Character]) -> void:
	draw_rect(rect, PANEL_COLOR)

	var font := ThemeDB.fallback_font
	var inner_w := rect.size.x - PANEL_PADDING * 2.0

	for i in team.size():
		var unit := team[i]
		var alpha := 1.0 if unit.is_alive() else DOWNED_ALPHA
		var row_y := rect.position.y + PANEL_PADDING + i * (ROW_HEIGHT + ROW_GAP)
		var x := rect.position.x + PANEL_PADDING

		# name
		var text_color := Color(TEXT_COLOR, alpha)
		draw_string(font, Vector2(x, row_y + NAME_FONT_SIZE), unit.char_name,
			HORIZONTAL_ALIGNMENT_LEFT, inner_w, NAME_FONT_SIZE, text_color)

		# hp bar, fill only, no numbers
		var bar_pos := Vector2(x, row_y + NAME_FONT_SIZE + BAR_GAP)
		var frac := float(unit.hp) / float(unit.max_hp)
		draw_rect(Rect2(bar_pos, Vector2(inner_w, BAR_HEIGHT)), BAR_BG_COLOR)
		draw_rect(Rect2(bar_pos, Vector2(inner_w * frac, BAR_HEIGHT)), Color(BAR_COLOR, alpha))

# Intentionally empty for now
# EX meter goes here, plus space for the portrait cut-in + ability name
func _draw_top_bar() -> void:
	draw_rect(GridConfig.top_bar_rect(), PANEL_COLOR)

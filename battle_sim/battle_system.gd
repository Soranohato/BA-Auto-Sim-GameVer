# The main battle loop where the battle occurs

class_name BattleSystem
extends RefCounted

const TICK_DURATION := 0.1 # tune this at some point

static func run_battle(team_a: Array[Character], team_b: Array[Character],
		target_strategy: String, cover_objects: Array[CoverObject],
		max_ticks: int = 500) -> void:
	var state := BattleState.new(team_a, team_b, target_strategy, cover_objects, max_ticks)
	attach_console_log(state)
	while not state.is_finished:
		state.tick()
		
# Public so main.gd can also attach it when running with graphics.
static func attach_console_log(state: BattleState) -> void:
	state.unit_moved.connect(_log_moved.bind(state))
	state.hit_resolved.connect(_log_hit.bind(state))
	state.missed.connect(func(a, d): print("%s missed %s!" % [a.char_name, d.char_name]))
	state.unit_downed.connect(func(u): print("  >> %s is down!" % u.char_name))
	state.cover_destroyed.connect(func(c): print("  >> %s was destroyed!" % c.cover_name))
	state.battle_finished.connect(_log_finished.bind(state))
	
static func _log_moved(unit: Character, state: BattleState) -> void:
	print("[t=%.1f] %s moved to %s" % [state.current_time, unit.char_name, unit.pos])


static func _log_hit(attacker: Character, defender: Character, dmg: int, crit: bool,
		cover: CoverObject, state: BattleState) -> void:
	var crit_tag := " (CRIT!)" if crit else ""
	var cover_tag := ""
	if cover != null:
		cover_tag = " (covered by %s, -%d%%)" % [cover.cover_name, int(cover.reduction * 100)]
	print("[t=%.1f] %s hits %s for %d%s%s [%s HP: %d/%d]" % [
		state.current_time, attacker.char_name, defender.char_name, dmg, crit_tag, cover_tag,
		defender.char_name, defender.hp, defender.max_hp,
	])


static func _log_finished(winner: String, state: BattleState) -> void:
	print("\n=== Battle Over ===")
	if winner == "":
		print("Draw / timed out.")
	else:
		print("Team %s wins! (t=%.1f)" % [winner, state.current_time])

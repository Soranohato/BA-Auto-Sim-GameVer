# Owns everything run_battle() used to hold as locals, and advances the
# sim exactly one tick per tick() call.

class_name BattleState
extends RefCounted

# Events for the visual layer. Emitted alongside (not instead of) print().
signal unit_moved(unit: Character)
signal shot_fired(attacker: Character, defender: Character)
signal hit_resolved(attacker: Character, defender: Character, dmg: int, crit: bool, cover: CoverObject)
signal missed(attacker: Character, defender: Character)
signal unit_downed(unit: Character)
signal cover_destroyed(cover: CoverObject)
signal battle_finished(winner: String)  # "A", "B", or "" for draw/timeout

const TICK_DURATION := 0.1

var team_a: Array[Character]
var team_b: Array[Character]
var all_units: Array[Character]
var cover_objects: Array[CoverObject]
var target_strategy: String
var current_time := 0.0
var tick_count := 0
var max_ticks := 500
var is_finished := false

func _init(a: Array[Character], b: Array[Character], strategy: String,
		cover: Array[CoverObject], max_ticks_in: int = 500) -> void:
	pass  # TODO: assign fields, build all_units, call Skills.apply_all_passives(all_units)

# Advance the sim by one TICK_DURATION. Body = the inside of the old while loop
# (reload -> ready check -> pick target -> move or fire -> per-bullet damage).
# Replace the print() calls with signal emits (keep prints if you still want them).
func tick() -> void:
	pass  # TODO: port loop body from BattleSystem.run_battle

func _check_finished() -> void:
	pass  # TODO: set is_finished + emit battle_finished(winner)

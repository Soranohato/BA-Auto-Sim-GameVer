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
	team_a = a
	team_b = b
	all_units = a + b
	target_strategy = strategy
	cover_objects = cover
	max_ticks = max_ticks_in
	Skills.apply_all_passives(all_units)  # mutates characters, so build one state per battle
	# NOTE: Skills.check_and_trigger_skills() still not called - active skills aren't ready

# Advance the sim by one TICK_DURATION. Body = the inside of the old while loop
# (reload -> ready check -> pick target -> move or fire -> per-bullet damage).
# Replace the print() calls with signal emits (keep prints if you still want them).
func tick() -> void:
	if is_finished:
		return
	if _has_winner() or tick_count >= max_ticks:
		_finish()
		return

	tick_count += 1
	current_time += TICK_DURATION

	for attacker in all_units:
		_step_unit(attacker)

	# Check again so battle_finished fires on the tick the last unit falls,
	# not one tick later.
	if _has_winner():
		_finish()

# One unit's turn for this tick. Early `return`s replace the old loop's `continue`s.
func _step_unit(attacker: Character) -> void:
	if not attacker.is_alive():
		return

	AmmoSystem.update_reload(attacker, current_time)
	if attacker.is_reloading:
		return
	if not AmmoSystem.is_ready_to_fire(attacker, current_time):
		return

	var enemies: Array[Character] = team_b if team_a.has(attacker) else team_a
	if not enemies.any(func(e): return e.is_alive()):
		return

	var defender: Character = CombatSystem.pick_target(attacker, enemies, target_strategy)

	if not Movement.is_in_range(attacker, defender):
		Movement.move_toward(attacker, defender, cover_objects, all_units)
		unit_moved.emit(attacker)
		return

	attacker.is_moving = false
	_fire_at(attacker, defender)
	attacker.next_shot_time = current_time + AmmoSystem.SHOT_COOLDOWN


func _fire_at(attacker: Character, defender: Character) -> void:
	var bullets: int = AmmoSystem.fire(attacker)
	if not attacker.has_ammo():
		AmmoSystem.start_reload(attacker, current_time)
	shot_fired.emit(attacker, defender)

	# Each bullet is its own dmg instance
	for bullet_num in range(bullets):
		var result: Array = DamageSystem.roll_damage(attacker, defender)
		var dmg: int = result[0]
		var crit: bool = result[1]

		if dmg == 0:
			missed.emit(attacker, defender)
			continue

		var cover_result: Array = CoverSystem.get_cover_reduction(defender, attacker, cover_objects)
		var cover_pct: float = cover_result[0]
		var provider: CoverObject = cover_result[1]
		var reduced_dmg := roundi(dmg * (1.0 - cover_pct))

		if provider != null:
			provider.take_damage(dmg - reduced_dmg)
			if provider.is_destroyed():
				cover_destroyed.emit(provider)

		defender.take_damage(reduced_dmg)
		hit_resolved.emit(attacker, defender, reduced_dmg, crit, provider)

		if not defender.is_alive():
			unit_downed.emit(defender)
			break  # TODO: retarget remaining bullets instead?


func _has_winner() -> bool:
	return not team_a.any(func(u): return u.is_alive()) \
		or not team_b.any(func(u): return u.is_alive())


func _finish() -> void:
	is_finished = true
	var a_alive := team_a.any(func(u): return u.is_alive())
	var b_alive := team_b.any(func(u): return u.is_alive())
	var winner := ""
	if a_alive and not b_alive:
		winner = "A"
	elif b_alive and not a_alive:
		winner = "B"
	battle_finished.emit(winner)

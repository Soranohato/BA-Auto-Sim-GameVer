# The main battle loop where the battle occurs

class_name BattleSystem
extends RefCounted

const TICK_DURATION := 0.1 # tune this at some point

static func run_battle(team_a: Array[Character], team_b: Array[Character],
		target_strategy: String, cover_objects: Array[CoverObject],
		max_ticks: int = 500) -> void:
	var all_units: Array[Character] = team_a + team_b
	var current_time := 0.0
	
	Skills.apply_all_passives(all_units)
	# NOTE: Skills.check_and_trigger_skills() is not called yet
	# as active skills are not ready
	
	var tick := 0
	while tick < max_ticks:
		var a_alive := team_a.any(func(u): return u.is_alive())
		var b_alive := team_b.any(func(u): return u.is_alive())
		if not a_alive or not b_alive:
			break
			
		tick += 1
		current_time += TICK_DURATION
		
		for attacker in all_units:
			if not attacker.is_alive():
				continue
			
			# Student cannot fire if reloading or not ready to fire
			AmmoSystem.update_reload(attacker, current_time)
			if attacker.is_reloading:
				continue
			if not AmmoSystem.is_ready_to_fire(attacker, current_time):
				continue
			
			# if there are no Students left on either side break the loop
			var enemies: Array[Character] = team_b if team_a.has(attacker) else team_a
			if not enemies.any(func(e): return e.is_alive()):
				break
				
			var defender: Character = CombatSystem.pick_target(attacker, enemies, target_strategy)
			
			# Student will move towards another student if none are in range
			if not Movement.is_in_range(attacker, defender):
				Movement.move_toward(attacker, defender, cover_objects, all_units)
				print("[t=%.1f] %s moved to %s" % [current_time, attacker.char_name, attacker.pos])
				continue
				
			var bullets: int = AmmoSystem.fire(attacker)
			if not attacker.has_ammo():
				AmmoSystem.start_reload(attacker, current_time)
				
			# Each bullet is its own dmg instance
			for bullet_num in range(bullets):
				var result: Array = DamageSystem.roll_damage(attacker, defender)
				var dmg: int = result[0]
				var crit: bool = result[1]

				if dmg == 0:
					print("%s missed %s!" % [attacker.char_name, defender.char_name])
					continue

				var cover_result: Array = CoverSystem.get_cover_reduction(defender, cover_objects)
				var cover: float = cover_result[0]
				var provider: CoverObject = cover_result[1]
				var reduced_dmg := roundi(dmg * (1.0 - cover))

				if provider != null:
					var absorbed := dmg - reduced_dmg
					provider.take_damage(absorbed)
					if provider.is_destroyed():
						print("  >> %s was destroyed!" % provider.cover_name)

				defender.take_damage(reduced_dmg)

				var crit_tag := " (CRIT!)" if crit else ""
				var cover_tag := " (covered by %s, -%d%%)" % [provider.cover_name, int(cover * 100)] if provider != null else ""
				print("[t=%.1f] %s hits %s for %d%s%s [%s HP: %d/%d]" % [
					current_time, attacker.char_name, defender.char_name, dmg, crit_tag, cover_tag,
					defender.char_name, defender.hp, defender.max_hp,
				])

				if not defender.is_alive():
					print("  >> %s is down!" % defender.char_name)
					break  # don't need to resolve extra bullets

			attacker.next_shot_time = current_time + AmmoSystem.SHOT_COOLDOWN
	
	# Ending the battle logic
	var a_alive_final := team_a.any(func(c): return c.is_alive())
	var b_alive_final := team_b.any(func(c): return c.is_alive())
	print("\n=== Battle Over ===")
	if a_alive_final and not b_alive_final:
		print("Team A wins! (t=%.1f)" % current_time)
	elif b_alive_final and not a_alive_final:
		print("Team B wins! (t=%.1f)" % current_time)
	else:
		print("Draw / timed out.")

# Ammo and reload mechanics.
#
# RELOAD_TIME and SHOT_COOLDOWN are global - identical for every student
# Per-character variation lives entirely in max_ammo and
# bullets_per_shot (roster.json).

class_name AmmoSystem
extends RefCounted

const RELOAD_TIME := 3.0
const SHOT_COOLDOWN := 0.5

static func is_ready_to_fire(character: Character, current_time: float) -> bool:
	return not character.is_reloading and character.has_ammo() and current_time >= character.next_shot_time

# called when ammo count hits 0, sets is_reloading and reload_end_time, this will occur
# the moment a character hits 0 ammo loaded
static func start_reload(character: Character, current_time: float) -> void:
	character.is_reloading = true
	character.reload_end_time = current_time + RELOAD_TIME

# called each tick, if the reload end time has passed, refill ammo and set is_reloading to False
# Note: a student can not move while reloading
static func update_reload(character: Character, current_time: float) -> void:
	if current_time >= character.reload_end_time and character.is_reloading:
		character.ammo = character.max_ammo
		character.is_reloading = false
		character.next_shot_time = current_time

# Fires the amount of bullets per burst a student can. For example if their burst is 3 and they
# have 3 ammo they will fire all 3. However, if their burst is 3 and they have 2 ammo left they 
# will only fire 2. Each bullet resolves it's own damage calculation as opposed to a lump sum

# This is only manages removing ammo from the character and how many bullets were fired, not the damage
static func fire(character: Character) -> int:
	if character.ammo <= 0:
		push_error("%s cannot fire: 0 ammo left" % character.char_name)
		return 0
	var bullets := mini(character.bullets_per_shot, character.ammo)
	character.ammo -= bullets
	return bullets

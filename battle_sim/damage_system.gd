class_name DamageSystem
extends RefCounted

# --- Accuracy/Evasion ---------------------------------------------------
const ACCURACY_CONSTANT := 666.666

static func get_hit_chance(attacker: Character, defender: Character) -> float:
	return minf(1.0, ACCURACY_CONSTANT / (defender.evasion - attacker.accuracy + ACCURACY_CONSTANT))

# --- Type effectiveness (Weakness) --------------------------------------
# TODO: build a Weak/Effective/Normal/Resist matchup table once
# atk_type/def_type are assigned beyond "Neutral". Multipliers from game:
#   Weak = 2x, Effective = 1.5x, Normal = 1x, Resist = 0.5x
#
# Originally did not implemented error here, now just logs
static func get_type_multiplier(attacker: Character, defender: Character) -> float:
	if attacker.atk_type == "Neutral" or defender.def_type == "Neutral":
		return 1.0
	push_error("DamageSystem: type matchup table not implemented yet")
	return 1.0

# --- Defense -------------------------------------------------------------
const DEF_MOD_CONSTANT := 1666.666
const DEF_REDUCTION_CAP := 0.8  # defense can reduce at most 80% of damage

static func get_def_mod(defense: int) -> float:
	var mod := DEF_MOD_CONSTANT / (DEF_MOD_CONSTANT + defense)
	return maxf(mod, 1.0 - DEF_REDUCTION_CAP)

# --- Damage Reduction / Damage Amplification ------------------------------
# TODO: sum active dmg-reduction / dmg-amplification buffs and debuffs
# once a buff/debuff system exists. An empty sum is genuinely 1.0 (no
# modifier), not a placeholder guess - see doc's DmgRedMod/DmgAmpMod formulas.
static func get_damage_reduction_mod(defender: Character) -> float:
	return 1.0

static func get_damage_amp_mod(attacker: Character) -> float:
	return 1.0

# --- Crit chance -----------------------------------------------------------
const CRIT_CHANCE_CONSTANT := 666.66

# crit_res has no base/roster component - it exists purely as a target for
# buffs/debuffs, which don't exist yet. 0 here is the correct "no resistance
# applied" value. TODO: source from buff/debuff system.
static func get_crit_res(defender: Character) -> int:
	return 0

static func get_crit_chance(attacker: Character, defender: Character) -> float:
	var final_crit := attacker.crit - get_crit_res(defender)
	return final_crit / float(final_crit + CRIT_CHANCE_CONSTANT)

# --- Crit damage -----------------------------------------------------------
const CRIT_DMG_DIVISOR := 10000.0

# Same pattern as get_crit_res above. TODO: source from buff/debuff system.
static func get_crit_dmg_res(defender: Character) -> int:
	return 0

static func get_crit_dmg_multiplier(attacker: Character, defender: Character) -> float:
	var final_crit_dmg := attacker.crit_dmg - get_crit_dmg_res(defender)
	return 1.0 + (final_crit_dmg / CRIT_DMG_DIVISOR)

# --- Stability / Variance ---------------------------------------------------
const STABILITY_DIVISOR := 1000.0
const STABILITY_CONSTANT := 0.2  # default, some skills/UEs alter this constant directly

static func get_damage_floor(attacker: Character) -> float:
	var floor_val := attacker.stability / (attacker.stability + STABILITY_DIVISOR) + STABILITY_CONSTANT
	return minf(floor_val, 1.0)  # ceiling is always 1.0, guard against floor exceeding it

static func roll_variance(attacker: Character) -> float:
	var floor_val := get_damage_floor(attacker)
	return randf_range(floor_val, 1.0)

# --- Entry point -------------------------------------------------------
# Returns [damage: int, was_crit: bool].
static func roll_damage(attacker: Character, defender: Character,
		skill_multiplier: float = 1.0, hit_count: int = 1) -> Array:
	var base_damage := (
		attacker.atk
		* get_type_multiplier(attacker, defender)
		* skill_multiplier
		* (1.0 / hit_count)
		* get_def_mod(defender.defense)
		* get_damage_reduction_mod(defender)
		* get_damage_amp_mod(attacker)
	)

	var is_crit := randf() < get_crit_chance(attacker, defender)
	if is_crit:
		base_damage *= get_crit_dmg_multiplier(attacker, defender)

	var final_damage := base_damage * roll_variance(attacker)

	var is_hit := randf() < get_hit_chance(attacker, defender)
	if not is_hit:
		return [0, false]

	return [roundi(maxf(1.0, final_damage)), is_crit]

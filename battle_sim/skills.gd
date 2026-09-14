# Normal / Passive / Sub skill system. EX skills intentionally excluded for now.
#
# Skills are heterogeneous enough per-character (different triggers, different
# effects, different targeting) So:
#
#   - Passives are static stat modifiers with no trigger - resolved once,
#     not part of the tick loop.
#   - Normal/Sub skills are a (trigger, effect) function pair evaluated per
#     tick, mirroring the "check readiness, then fire" split already used in
#     ammo.py (is_ready_to_fire -> fire).
#
# This keeps the battle.py tick loop change to one hook call per unit, while
# leaving all the actual per-character numbers/logic here to fill in.

class_name Skills
extends RefCounted

# ---------------------------------------------------------------------------
# Passive skills
# ---------------------------------------------------------------------------
# Always-on stat modifiers, applied once (right after roster load / position
# assignment), not evaluated per-tick.

class PassiveSkill:
	var skill_name: String
	var stat: String       # must match a Character property name, e.g. "defense"
	var percent: float     # e.g. 0.266 for +26.6%

	func _init(skill_name_in: String, stat_in: String, percent_in: float) -> void:
		skill_name = skill_name_in
		stat = stat_in
		percent = percent_in

	func apply(character: Character) -> void:
		var current: float = character.get(stat)
		character.set(stat, current * (1.0 + percent))
		print("applied %s%% %s to %s" % [percent * 100, stat, character.char_name])

# TODO: fill in real names/values; shape mirrors roster.json (name -> skill data)
static var PASSIVES: Dictionary = {
	"Hoshino": PassiveSkill.new("HoshinoPassive", "defense", 0.266),
	"Aru": PassiveSkill.new("AruPassive", "crit_dmg", 0.266),
}

static func apply_all_passives(characters: Array[Character]) -> void:
	for c in characters:
		if PASSIVES.has(c.char_name):
			var passive: PassiveSkill = PASSIVES[c.char_name]
			passive.apply(c)


# ---------------------------------------------------------------------------
# Normal / Sub skills
# ---------------------------------------------------------------------------
# `context` is a grab-bag Dictionary for whatever a trigger/effect needs
# (all_units, enemies, cover_objects - current_time is passed separately
# since nearly everything needs it). TODO: pin down the exact shape
# once you know what each skill actually needs.

class ActiveSkill:
	var skill_name: String
	var kind: String  # "normal" or "sub"
	var trigger: Callable
	var effect: Callable
	var max_uses: Variant  # int, or null = unlimited (e.g. Aru's repeating 25s normal)

	func _init(skill_name_in: String, kind_in: String, trigger_in: Callable,
			effect_in: Callable, max_uses_in: Variant = null) -> void:
		skill_name = skill_name_in
		kind = kind_in
		trigger = trigger_in
		effect = effect_in
		max_uses = max_uses_in


# --- Hoshino -----------------------------------------------------------

static func _hoshino_normal_trigger(character: Character, current_time: float, context: Dictionary) -> bool:
	push_error("Skills: _hoshino_normal_trigger not implemented")  # TODO: hp <= 30% of max_hp AND not yet used this battle
	return false

static func _hoshino_normal_effect(character: Character, current_time: float, context: Dictionary) -> void:
	push_error("Skills: _hoshino_normal_effect not implemented")  # TODO: start a 20s HoT worth 191% of Healing Power (stat doesn't exist yet)

static func _hoshino_sub_trigger(character: Character, current_time: float, context: Dictionary) -> bool:
	push_error("Skills: _hoshino_sub_trigger not implemented")  # TODO: fires on EX activation - no EX system yet, nothing to hook into
	return false

static func _hoshino_sub_effect(character: Character, current_time: float, context: Dictionary) -> void:
	push_error("Skills: _hoshino_sub_effect not implemented")  # TODO: grant a shield worth 205% Healing Power


# --- Aru -----------------------------------------------------------------

static func _aru_normal_trigger(character: Character, current_time: float, context: Dictionary) -> bool:
	push_error("Skills: _aru_normal_trigger not implemented")  # TODO: fires every 25s, independent of the ammo/reload clock
	return false

static func _aru_normal_effect(character: Character, current_time: float, context: Dictionary) -> void:
	push_error("Skills: _aru_normal_effect not implemented")
	# TODO: 290% hit on primary target; 50% roll for 476% AOE hit around
	# the target - needs a "living units within radius of point" helper that
	# doesn't exist yet (candidate home: CombatSystem or a new AoeSystem)

static func _aru_sub_trigger(character: Character, current_time: float, context: Dictionary) -> bool:
	push_error("Skills: _aru_sub_trigger not implemented")  # TODO: passive-like, but scoped to EX crit rate only - no EX system yet
	return false

static func _aru_sub_effect(character: Character, current_time: float, context: Dictionary) -> void:
	push_error("Skills: _aru_sub_effect not implemented")  # TODO: +38.3% crit rate applied only to EX hits


# TODO: registry mirrors roster.json/PASSIVES shape
static var ACTIVE_SKILLS: Dictionary = {
	"Hoshino": [
		ActiveSkill.new("normal", "normal", _hoshino_normal_trigger, _hoshino_normal_effect, 1),
		ActiveSkill.new("sub", "sub", _hoshino_sub_trigger, _hoshino_sub_effect),
	],
	"Aru": [
		ActiveSkill.new("normal", "normal", _aru_normal_trigger, _aru_normal_effect),
		ActiveSkill.new("sub", "sub", _aru_sub_trigger, _aru_sub_effect),
	],
}

# Call once per living unit per tick from the battle loop.
static func check_and_trigger_skills(character: Character, current_time: float, context: Dictionary) -> void:
	if not ACTIVE_SKILLS.has(character.char_name):
		return
	for skill: ActiveSkill in ACTIVE_SKILLS[character.char_name]:
		# TODO: per-skill state (uses remaining, cooldown/next-trigger
		# time, active HoT/shield tracking) needs a home - Character fields?
		# a side dict keyed by (character, skill.skill_name)? decide before
		# wiring up.
		if skill.trigger.call(character, current_time, context):
			skill.effect.call(character, current_time, context)

# The character roster. Loaded from data/roster.json

class_name RosterLoader
extends RefCounted

const DATA_PATH := "res://data/roster.json"

const _INT_STATS := [
	"max_hp", "atk", "defense", "spd", "max_ammo", "bullets_per_shot",
	"stability", "crit", "crit_dmg", "accuracy", "evasion",
]

static func make_roster() -> Dictionary:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("RosterLoader: could not open %s (error %d)" % [DATA_PATH, FileAccess.get_open_error()])
		return {}

	var text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("RosterLoader: %s did not parse as a JSON object" % DATA_PATH)
		return {}

	var roster: Dictionary = {}
	for key in parsed.keys():
		var char_name: String = key
		var raw_stats: Dictionary = parsed[char_name]
		roster[char_name] = Character.new(char_name, _coerce_int_stats(raw_stats))

	return roster

static func _coerce_int_stats(raw_stats: Dictionary) -> Dictionary:
	var stats := raw_stats.duplicate()
	for key in _INT_STATS:
		if stats.has(key):
			stats[key] = int(stats[key])
	return stats

#The Character data model - just stats and state, no combat logic here.

class_name Character
extends RefCounted

# Required roster stats
var char_name: String
var max_hp: int
var atk: int
var defense: int
var spd: int
var atk_range: float
var max_ammo: int
var bullets_per_shot: int
var stability: int
var crit: int
var crit_dmg: int
var accuracy: int
var evasion: int

# Optional, roster.json may omit these as there are defualts
var role: String = "striker"
var atk_type: String = "Neutral"
var def_type: String = "Neutral"

# Runtime stats
var pos: Vector2 = Vector2.ZERO
var side: String = ""
var hp: int
var is_moving: bool = false
var ammo: int
var is_reloading: bool = false
var next_shot_time: float = 0.0
var reload_end_time: float = 0.0

const _REQUIRED_STATS := [
	"max_hp", "atk", "defense", "spd", "atk_range", "max_ammo",
	"bullets_per_shot", "stability", "crit", "crit_dmg", "accuracy", "evasion",
]

func _init(name_in: String, stats: Dictionary) -> void:
	for key in _REQUIRED_STATS:
		if not stats.has(key):
			push_error("Character '%s' missing required stat: %s" % [name_in, key])
			return

	char_name = name_in
	max_hp = stats["max_hp"]
	atk = stats["atk"]
	defense = stats["defense"]
	spd = stats["spd"]
	atk_range = stats["atk_range"]
	max_ammo = stats["max_ammo"]
	bullets_per_shot = stats["bullets_per_shot"]
	stability = stats["stability"]
	crit = stats["crit"]
	crit_dmg = stats["crit_dmg"]
	accuracy = stats["accuracy"]
	evasion = stats["evasion"]

	role = stats.get("role", "striker")
	atk_type = stats.get("atk_type", "Neutral")
	def_type = stats.get("def_type", "Neutral")

	hp = max_hp
	ammo = max_ammo
	
func is_alive() -> bool:
	return hp > 0

func has_ammo() -> bool:
	return ammo > 0

func take_damage(amount: int) -> void:
	hp = max(0, hp - amount)

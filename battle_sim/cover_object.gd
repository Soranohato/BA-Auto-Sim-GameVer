# handles cover object states

class_name CoverObject
extends RefCounted

var cover_name: String
var pos: Vector2
var reduction: float
var hp: Variant  # int, or null = indestructible

func _init(name_in: String, pos_in: Vector2, reduction_in: float, hp_in: Variant = null) -> void:
	cover_name = name_in
	pos = pos_in
	reduction = reduction_in
	hp = hp_in

func is_destroyed() -> bool:
	if hp == null:
		return false  # indestructible
	return hp <= 0

func take_damage(amount: int) -> void:
	if hp == null:
		return  # indestructible so nothing to reduce
	hp = max(0, hp - amount)

extends Node

func _ready() -> void:
	var roster := RosterLoader.make_roster()
	if roster.is_empty():
		push_error("Roster failed to load")
		return

	var team_a: Array[Character] = [roster["Hoshino"], roster["Aru"], roster["Hifumi"]]
	var team_b: Array[Character] = [roster["Iori"], roster["Atsuko"], roster["Yuzu"]]

	GridConfig.assign_positions(team_a, "A")
	GridConfig.assign_positions(team_b, "B")

	for c in team_a + team_b:
		print("%s: %s (%s)" % [c.char_name, c.pos, c.role])

# Script that initiates the battle and builds the starting field

extends Node

func _ready() -> void:
	var roster: Dictionary = RosterLoader.make_roster()
	if roster.is_empty():
		push_error("Roster failed to load")
		return

	var cover: Array[CoverObject] = CoverSystem.make_cover_layout(2, true)
	var strategy := "nearest"

	var team_a: Array[Character] = [roster["Hoshino"], roster["Aru"], roster["Hifumi"]]
	var team_b: Array[Character] = [roster["Iori"], roster["Atsuko"], roster["Yuzu"]]

	GridConfig.assign_positions(team_a, "A")
	GridConfig.assign_positions(team_b, "B")

	print("Positions:")
	for c in team_a + team_b:
		print("  %s: %s (%s)" % [c.char_name, c.pos, c.role])

	print("Cover Objects:")
	for obj in cover:
		print("  %s: %s" % [obj.cover_name, obj.pos])

	BattleSystem.run_battle(team_a, team_b, strategy, cover)

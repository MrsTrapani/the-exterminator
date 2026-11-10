extends Node

signal boss_cast_started(cast_name: String, duration: float)

signal upgrade_selected

signal loadout_requested
signal selected_skill
signal hovered_skill

func emit_upgrade_selected(selection: Node3D) -> void:
	upgrade_selected.emit(selection)

func emit_loadout_requested(opening_loadout: bool) -> void:
	loadout_requested.emit(opening_loadout)

func emit_selected_skill(skill: SkillResource) -> void:
	selected_skill.emit(skill)

func emit_hovered_skill(skill: SkillResource) -> void:
	hovered_skill.emit(skill)

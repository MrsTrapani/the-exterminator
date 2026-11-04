extends Node3D

@export var debug: bool = false
@export var debug_skills: Array[SkillResource]
@export var battle_ui: Control

func _ready() -> void:
	if debug:
		GameState.skills = debug_skills.duplicate()
		GameState.skill_selected = GameState.skills.size()
		battle_ui.update_skillbar()

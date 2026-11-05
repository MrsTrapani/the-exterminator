extends Node3D

@export var debug: bool = false
@export var debug_skills: Array[SkillResource]
@export var battle_ui: Control

func _ready() -> void:
	if debug:
		GameState.skills = debug_skills.duplicate()
		GameState.skill_selected = GameState.skills.size()
		battle_ui.update_skillbar()


func _on_aggro_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not battle_ui.battle_started:
		battle_ui.start_battle()

extends Node3D

@export var debug: bool = false
@export var debug_skills: Array[SkillResource]
@export var battle_ui: Control
@export var boss_intro_ui: Control
@export var pause_ui: Control

@onready var arena_bottom: Node3D = $Arena/Arena_Bottom
@onready var arena_decal: MeshInstance3D = $Arena/ArenaDecal
@onready var decor: Node3D = $Arena/Decor
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_3d: Camera3D = $Camera3D




func _ready() -> void:
	pause_ui.hide()
	if debug and GameState.skills.is_empty():
		GameState.skills = debug_skills.duplicate()
		GameState.skill_selected = GameState.skills.size()
	battle_ui.update_skillbar()
	if GameState.is_loading:
		battle_ui.player.can_move = false
		await GameState.battle_loading_finished
		battle_ui.player.can_move = true
	if not GameState.boss1_intro_seen:
		camera_3d.current = true
		animation_player.play("boss_intro")
		await boss_intro_ui.play_boss_info_anim()
		camera_3d.current = false
		GameState.boss1_intro_seen = true
	if not GameState.boss_1_tutorial_seen:
		battle_ui.show_tutorial()
	

func _on_aggro_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not battle_ui.battle_started:
		battle_ui.start_battle()


func _physics_process(delta: float) -> void:
	arena_bottom.rotation_degrees.y -= (360.0 / 20) * delta
	arena_decal.rotation_degrees.y -= (360.0 / 120) * delta
	decor.rotation_degrees.y += (360.0 / 120) * delta

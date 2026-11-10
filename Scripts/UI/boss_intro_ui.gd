extends Control

@onready var spinning_icon: TextureRect = $SpinningIcon
@onready var map_name: RichTextLabel = $MapName
@onready var boss_name: RichTextLabel = $BossName
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var player: CharacterBody3D

var is_spinning: bool = false

func _ready() -> void:
	animation_player.play("RESET")
	spinning_icon.modulate = Color(1.0, 1.0, 1.0, 0.0)

func _physics_process(delta: float) -> void:
	if is_spinning:
		spinning_icon.rotation -= (5.0 / 20) * delta

func play_boss_info_anim() -> void:
	player.can_move = false
	is_spinning= true
	animation_player.play("on_spawn")
	await animation_player.animation_finished
	animation_player.play_backwards("on_spawn")
	await animation_player.animation_finished
	is_spinning = false
	spinning_icon.modulate = Color(1.0, 1.0, 1.0, 0.0)
	player.can_move = true

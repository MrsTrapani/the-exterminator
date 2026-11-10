@tool
extends "res://Externals/Binbun/BinbunVFX/shared/script/vfx_controller.gd"

@onready var core: GPUParticles3D = $Core
@onready var decal: Decal = $Decal
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	animation_player.animation_finished.connect(effect_finished)
	stop_effect()

func play_effect() -> void:
	show()
	animation_player.stop()
	core.restart()
	animation_player.play("main")
	animation_player.advance(0.0)

func stop_effect() -> void:
	animation_player.stop()
	core.emitting = false
	decal.albedo_mix = 0.0
	decal.emission_energy = 0.0
	hide()

func effect_finished(_animation: StringName) -> void:
	stop_effect()

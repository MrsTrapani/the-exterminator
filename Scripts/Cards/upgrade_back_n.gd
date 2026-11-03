extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var can_flip: bool = false

func _ready() -> void:
	animation_player.play("RESET")

func _on_area_3d_mouse_entered() -> void:
	if can_flip:
		zoom_card()

func _on_area_3d_mouse_exited() -> void:
	if can_flip:
		unzoom_card()

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("lmb"):
		select_card()

func flip_card() -> void:
	animation_player.play("flip")
	await animation_player.animation_finished
	can_flip = true

func zoom_card() -> void:
	animation_player.play("zoom")

func unzoom_card() -> void:
	animation_player.play_backwards("zoom")

func select_card() -> void:
	can_flip = false
	SignalHub.emit_upgrade_selected(self)
	animation_player.speed_scale = 0.7
	animation_player.play("selected")
	await animation_player.animation_finished
	queue_free()

func despawn_card() -> void:
	can_flip = false
	animation_player.play("despawn")
	await animation_player.animation_finished
	queue_free()

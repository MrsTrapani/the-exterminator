extends Node3D

@onready var interact_area: Area3D = $"../InteractArea"

@onready var interact_prompt: Sprite3D = $"../InteractPrompt"


var player: Node3D
var interacted: bool = false

func _ready() -> void:
	interact_prompt.hide()
	interact_area.body_entered.connect(player_entered)
	interact_area.body_exited.connect(player_exited)

func player_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not interacted:
		player = body
		interact_prompt.show()


func player_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		interact_prompt.hide()

func _input(event: InputEvent) -> void:
	if not interacted and event.is_action_pressed("interact"):
		player.stop_camera_rotation()
		player.can_move = false
		get_viewport().set_input_as_handled()
		SignalHub.emit_loadout_requested(true)

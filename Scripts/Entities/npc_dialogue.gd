extends CharacterBody3D

@export var dialogue: DialogueResource
@export var start_cue: String = "start"
@export var balloon_scene: PackedScene
@onready var interact_area: Area3D = $InteractArea
@onready var interact_prompt: Sprite3D = $InteractPrompt
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var player: Node3D
var dialogue_balloon: Node
var talking: bool = false


func _ready() -> void:
	interact_prompt.hide()
	sprite.play("Idle_F")
	interact_area.body_entered.connect(player_entered)
	interact_area.body_exited.connect(player_exited)


func player_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player = body
		interact_prompt.visible = not talking


func player_exited(body: Node3D) -> void:
	if body == player and not talking:
		player = null
		interact_prompt.hide()


func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(player) and not talking and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		start_dialogue()


func _input(event: InputEvent) -> void:
	if talking and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		dialogue_balloon.queue_free()


func start_dialogue() -> void:
	if dialogue == null or not player.can_move:
		return
	talking = true
	interact_prompt.hide()
	player.stop_camera_rotation()
	player.can_move = false
	dialogue_balloon = Engine.get_singleton("DialogueManager").show_dialogue_balloon_scene(balloon_scene, dialogue, start_cue)
	dialogue_balloon.next_action = &"interact"
	dialogue_balloon.skip_action = &"interact"
	dialogue_balloon.tree_exited.connect(finish_dialogue, CONNECT_ONE_SHOT)


func finish_dialogue() -> void:
	talking = false
	dialogue_balloon = null
	if is_instance_valid(player):
		player.can_move = true
		interact_prompt.visible = interact_area.overlaps_body(player)


func _exit_tree() -> void:
	if is_instance_valid(dialogue_balloon):
		dialogue_balloon.queue_free()
	if talking and is_instance_valid(player):
		player.can_move = true

extends CanvasLayer

@export var next_action: StringName = &"interact"
@export var skip_action: StringName = &"interact"

@onready var balloon: Control = %Balloon
@onready var character_label: RichTextLabel = %CharacterLabel
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var progress: Polygon2D = %Progress

var dialogue_resource: DialogueResource
var dialogue_line: DialogueLine
var game_states: Array = []
var loading_line: bool = false


func _ready() -> void:
	balloon.hide()
	progress.hide()


func start(resource: DialogueResource, cue: String = "start", extra_game_states: Array = []) -> void:
	dialogue_resource = resource
	game_states = extra_game_states
	next(cue)


func next(next_id: String) -> void:
	loading_line = true
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, game_states)
	loading_line = false

	if dialogue_line == null:
		queue_free()
		return

	character_label.text = dialogue_line.character
	character_label.visible = not dialogue_line.character.is_empty()
	dialogue_label.dialogue_line = dialogue_line
	balloon.show()
	dialogue_label.type_out()


func _process(_delta: float) -> void:
	progress.visible = dialogue_line != null and not loading_line and not dialogue_label.is_typing


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()
		return

	if loading_line or dialogue_line == null:
		return

	if event.is_action_pressed(next_action) or event.is_action_pressed(skip_action):
		get_viewport().set_input_as_handled()
		if dialogue_label.is_typing:
			dialogue_label.skip_typing()
		else:
			next(dialogue_line.next_id)

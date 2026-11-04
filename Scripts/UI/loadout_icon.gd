extends Control

@onready var icon: TextureRect = $IconMask/Icon

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var selected: TextureRect = $Selected
@onready var selector: TextureRect = $Selector
@onready var button: Button = $Button

@export var skill_resource: SkillResource

var is_selected: bool = false
var is_hovered: bool = false

func _ready() -> void:
	animation_player.play("selection")
	selected.hide()
	selector.hide()
	icon.texture = skill_resource.skill_icon
	

func _on_button_mouse_entered() -> void:
	if not is_selected:
		selector.show()
		is_hovered = true
		SignalHub.emit_hovered_skill(skill_resource)

func _on_button_mouse_exited() -> void:
	if not is_selected:
		selector.hide()
		is_hovered = false


func _on_button_pressed() -> void:
	if is_selected:
		is_selected = false
		selected.hide()
		GameState.skill_selected -= 1
		GameState.skills.erase(skill_resource)
		SignalHub.emit_selected_skill(skill_resource)

	elif not is_selected:
		if GameState.skill_selected < 4:
			GameState.skills.append(skill_resource)
			SignalHub.emit_selected_skill(skill_resource)
			is_selected = true
			selected.show()
			selector.hide()
			GameState.skill_selected += 1
		else:
			pass

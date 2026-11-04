extends Control

@onready var icon: TextureRect = $IconMask/Icon

@export var slot_number: int = 1

func _ready() -> void:
	SignalHub.selected_skill.connect(update_skill)
	update_skill()

func update_skill(_skill_resource: SkillResource = null) -> void:
	var index: int = slot_number - 1

	if index < GameState.skills.size():
		icon.texture = GameState.skills[index].skill_icon
	else:
		icon.texture = null

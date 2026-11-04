extends Node

@export var battle_ui: Control
@export var cooldown_message: String

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("skill_shift"):
		if battle_ui.cooldowns[0] > 0.0:
			battle_ui.update_error(cooldown_message)
			return
		print((GameState.skills[0].skill_name), " activated")
		battle_ui.start_skill_cooldown(0)
	if Input.is_action_just_pressed("skill_1"):
		if battle_ui.cooldowns[1] > 0.0:
			battle_ui.update_error(cooldown_message)
			return
		print((GameState.skills[1].skill_name), " activated")
		battle_ui.start_skill_cooldown(1)
	if Input.is_action_just_pressed("skill_2"):
		if battle_ui.cooldowns[2] > 0.0:
			battle_ui.update_error(cooldown_message)
			return
		print((GameState.skills[2].skill_name), " activated")
		battle_ui.start_skill_cooldown(2)
	if Input.is_action_just_pressed("skill_3"):
		if battle_ui.cooldowns[3] > 0.0:
			battle_ui.update_error(cooldown_message)
			return
		print((GameState.skills[3].skill_name), " activated")
		battle_ui.start_skill_cooldown(3)

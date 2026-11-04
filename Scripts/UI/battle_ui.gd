extends Control

@export var player: CharacterBody3D

@onready var icon_1: Control = $SkillBar/Icon
@onready var icon_2: Control = $SkillBar/Icon2
@onready var icon_3: Control = $SkillBar/Icon3
@onready var icon_4: Control = $SkillBar/Icon4

@onready var cd_1: Label = $SkillBar/Icon/CD
@onready var cd_2: Label = $SkillBar/Icon2/CD
@onready var cd_3: Label = $SkillBar/Icon3/CD
@onready var cd_4: Label = $SkillBar/Icon4/CD
@onready var cd_labels: Array[Label] = [cd_1, cd_2, cd_3, cd_4]

@onready var hp_bar: TextureProgressBar = $HPBar
@onready var cast_bar: TextureProgressBar = $CastBar
@onready var error: Label = $Error

var error_triggered: bool = false

var cooldowns: Array[float] = [0.0, 0.0, 0.0, 0.0]

func _ready() -> void:
	cast_bar.hide()
	error.hide()
	
	hp_bar.max_value = player.max_health
	hp_bar.value = player.current_health

	for label in cd_labels:
		label.hide()

func _process(delta: float) -> void:
	for i in range(4):
		if cooldowns[i] > 0.0:
			cooldowns[i] = maxf(0.0, cooldowns[i] - delta)
			cd_labels[i].text = str(ceili(cooldowns[i])) + "s"
			cd_labels[i].visible = cooldowns[i] > 0.0

func update_skillbar(_skill_resource: SkillResource = null) -> void:
	for slot in [icon_1, icon_2, icon_3, icon_4]:
		slot.call("update_skill")
	
	cd_1.text = str(GameState.skills[0].skill_cooldown)
	cd_2.text = str(GameState.skills[1].skill_cooldown)
	cd_3.text = str(GameState.skills[2].skill_cooldown)
	cd_4.text = str(GameState.skills[3].skill_cooldown)

func start_skill_cooldown(index: int) -> void:
	if index < 0 or index >= GameState.skills.size() or index >= 4:
		return
	if cooldowns[index] > 0.0:
		return
	var duration: float = GameState.skills[index].skill_cooldown
	if duration > 0.0:
		cooldowns[index] = duration
		cd_labels[index].text = str(ceili(duration)) + "s"
		cd_labels[index].show()

func update_error(message: String) -> void:
	if not error_triggered:
		error.show()
		error_triggered = true
		error.text = message
		await get_tree().create_timer(3.0).timeout
		error.hide()
		error.text = ""
		error_triggered = false
	

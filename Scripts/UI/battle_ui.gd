extends Control

@export var player: CharacterBody3D

@onready var tutorial: Control = $Tutorial

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
@onready var boss_cast_bar: TextureProgressBar = $BossCastBar
@onready var boss_cast_label: Label = $BossSpellName
@onready var error: Label = $Error
@onready var cast_bar_label: Label = $BossCastBar/Label
@onready var game_over: Control = $GameOver
@onready var battle_manager: Node = $"../BattleManager"
@onready var player_cast_label: Label = $CastBar/Label
@onready var boss_hp_bar: TextureProgressBar = $BossHPBar
@onready var boss: CharacterBody3D = $"../Boss1"
@onready var battle_start: Label = $BattleStart

@onready var boss_speech: TextureRect = $BossSpeech
@onready var boss_text: Label = $BossSpeech/BossText



var error_triggered: bool = false

var cooldowns: Array[float] = [0.0, 0.0, 0.0, 0.0]

var battle_started: bool = false
var boss_cast_tween: Tween

func _ready() -> void:
	boss_speech.hide()
	battle_start.hide()
	cast_bar.hide()
	cast_bar.step = 0.0
	boss_hp_bar.max_value = boss.max_health
	boss_hp_bar.value = boss.current_health
	boss.health_changed.connect(update_boss_health)
	boss_cast_bar.hide()
	boss_cast_label.hide()
	cast_bar_label.hide()
	boss_cast_bar.step = 0.0
	SignalHub.boss_cast_started.connect(start_boss_cast)
	error.hide()
	tutorial.hide()
	
	hp_bar.max_value = player.max_health
	hp_bar.value = player.current_health
	player.health_changed.connect(update_health)
	player.died.connect(player_died)
	game_over.hide()

	for label in cd_labels:
		label.hide()
	
	if get_tree().root.has_node("BattleFade"):
		player.can_move = false

func show_tutorial() -> void:
	player.can_move = false
	tutorial.show()

func _process(delta: float) -> void:
	for i in range(4):
		if cooldowns[i] > 0.0:
			cooldowns[i] = maxf(0.0, cooldowns[i] - delta)
			cd_labels[i].text = str(ceili(cooldowns[i])) + "s"
			cd_labels[i].visible = cooldowns[i] > 0.0

func start_boss_cast(cast_name: String, duration: float) -> void:
	if player.is_dead:
		return
	if boss_cast_tween and boss_cast_tween.is_valid():
		boss_cast_tween.kill()
	boss_cast_bar.hide()
	boss_cast_label.hide()
	if duration <= 0.0:
		return
	boss_cast_label.text = cast_name
	boss_cast_label.show()
	boss_cast_bar.max_value = duration
	boss_cast_bar.value = 0.0
	boss_cast_bar.show()
	boss_cast_tween = create_tween()
	boss_cast_tween.tween_property(boss_cast_bar, "value", duration, duration)
	boss_cast_tween.tween_callback(boss_cast_bar.hide)
	boss_cast_tween.tween_callback(boss_cast_label.hide)


func update_skillbar(_skill_resource: SkillResource = null) -> void:
	for slot in [icon_1, icon_2, icon_3, icon_4]:
		slot.call("update_skill")
	
	for i in range(cd_labels.size()):
		if i < GameState.skills.size() and GameState.skills[i] != null:
			cd_labels[i].text = str(GameState.skills[i].skill_cooldown)
		else:
			cd_labels[i].text = ""

func start_skill_cooldown(index: int) -> void:
	if index < 0 or index >= GameState.skills.size() or index >= 4:
		return
	if GameState.skills[index] == null:
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
		await get_tree().create_timer(3.0, false).timeout
		error.hide()
		error.text = ""
		error_triggered = false

func start_battle() -> void:
	battle_manager.start_battle()
	battle_start.show()
	await get_tree().create_timer(2.0).timeout
	battle_start.hide()

func update_health() -> void:
	hp_bar.value = player.current_health

func update_boss_health() -> void:
	boss_hp_bar.value = boss.current_health

func start_player_cast(skill_name: String, duration: float) -> void:
	player_cast_label.text = skill_name
	cast_bar.max_value = duration
	cast_bar.value = 0.0
	cast_bar.show()

func stop_player_cast() -> void:
	cast_bar.hide()

func reset_other_cooldowns(index: int) -> void:
	for i in range(cooldowns.size()):
		if i != index:
			cooldowns[i] = 0.0
			cd_labels[i].text = ""
			cd_labels[i].hide()

func stop_boss_cast() -> void:
	if boss_cast_tween and boss_cast_tween.is_valid():
		boss_cast_tween.kill()
	boss_cast_bar.hide()
	boss_cast_label.hide()

func player_died() -> void:
	stop_boss_cast()
	if get_tree().root.has_node("BattleFade"):
		return
	var fade := preload("res://Scripts/UI/battle_fade.gd").new()
	fade.name = "BattleFade"
	get_tree().root.add_child(fade)
	fade.reset_battle()


func _on_proceed_button_pressed() -> void:
	tutorial.hide()
	GameState.boss_1_tutorial_seen = true
	player.can_move = true

func show_boss_speech(dialogue: String) -> void:
	boss_speech.show()
	boss_text.text = dialogue
	await get_tree().create_timer(5.0).timeout
	boss_speech.hide()
	boss_text.text = ""

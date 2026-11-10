extends Control

@onready var pause_menu: Control = $Pause
@onready var guide: Control = $Guide
@onready var resume_button: TextureButton = $Pause/PauseMenu/ResumeButton
@onready var guide_button: TextureButton = $Pause/PauseMenu/GuideButton
@onready var restart_button: TextureButton = $Pause/PauseMenu/RestartButton
@onready var next_button: TextureButton = $Guide/Next
@onready var back_button: TextureButton = $Guide/Back
@onready var guide_pages: Array[Control] = [$Guide/RingtoneGuide, $Guide/HourStrikeGuide, $Guide/QuarterChimeGuide, $Guide/RHSGuide, $Guide/RavenousGuide]
@onready var player: CharacterBody3D = $"../Player"
@onready var battle_ui: Control = $"../BattleUI"
@onready var battle_manager: Node = $"../BattleManager"
@onready var resume_button_guide: TextureButton = $Guide/ResumeButton


var page: int = 0
var previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

func _ready() -> void:
	resume_button.pressed.connect(resume_game)
	resume_button_guide.pressed.connect(resume_game)
	guide_button.pressed.connect(open_guide)
	restart_button.pressed.connect(restart_battle)
	next_button.pressed.connect(next_page)
	back_button.pressed.connect(previous_page)
	for child in find_children("*", "Control", true, false):
		if not child is BaseButton:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guide.hide()
	hide()

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause") or event.is_echo():
		return
	if visible:
		if guide.visible:
			close_guide()
		else:
			resume_game()
	elif not GameState.is_loading and GameState.boss_1_tutorial_seen and GameState.boss1_intro_seen and not player.is_dead and not get_tree().root.has_node("BattleFade"):
		pause_game()
	get_viewport().set_input_as_handled()

func pause_game() -> void:
	player.stop_camera_rotation()
	previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	guide.hide()
	pause_menu.show()
	show()
	get_tree().paused = true
	resume_button.grab_focus()

func resume_game() -> void:
	hide()
	get_tree().paused = false
	Input.mouse_mode = previous_mouse_mode

func open_guide() -> void:
	pause_menu.hide()
	guide.show()
	page = 0
	update_page()
	next_button.grab_focus()

func close_guide() -> void:
	guide.hide()
	pause_menu.show()
	guide_button.grab_focus()

func next_page() -> void:
	page = mini(page + 1, guide_pages.size() - 1)
	update_page()

func previous_page() -> void:
	if page == 0:
		close_guide()
		return
	page -= 1
	update_page()

func update_page() -> void:
	for i in range(guide_pages.size()):
		guide_pages[i].visible = i == page
	next_button.disabled = page == guide_pages.size() - 1

func restart_battle() -> void:
	resume_game()
	player.can_move = false
	battle_manager.stop_battle()
	battle_ui.player_died()

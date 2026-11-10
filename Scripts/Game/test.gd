extends Node3D

@export var loadout_ui: Control
var is_leaving: bool = false

func _ready() -> void:
	loadout_ui.hide()
	SignalHub.loadout_requested.connect(show_loadout)
	loadout_ui.loadout_confirmed.connect(enter_battle)

func enter_battle() -> void:
	if is_leaving:
		return
	is_leaving = true
	var result := get_tree().change_scene_to_file("res://_Scene/UI/battle_loading.tscn")
	if result != OK:
		is_leaving = false
		loadout_ui.update_button()
		push_error("Could not open battle loading screen: " + error_string(result))

func show_loadout(is_opening: bool) -> void:
	if is_opening:
		loadout_ui.show()
		loadout_ui.unfurl_loadout()
	if not is_opening:
		loadout_ui.hide()
		loadout_ui.close_loadout()

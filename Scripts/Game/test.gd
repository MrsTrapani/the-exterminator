extends Node3D

@export var loadout_ui: Control

func _ready() -> void:
	loadout_ui.hide()
	SignalHub.loadout_requested.connect(show_loadout)

func show_loadout(is_opening: bool) -> void:
	if is_opening:
		loadout_ui.show()
		loadout_ui.unfurl_loadout()
	if not is_opening:
		loadout_ui.hide()
		loadout_ui.close_loadout()

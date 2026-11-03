extends Node

signal upgrade_selected

func emit_upgrade_selected(selection: Node3D) -> void:
	upgrade_selected.emit(selection)

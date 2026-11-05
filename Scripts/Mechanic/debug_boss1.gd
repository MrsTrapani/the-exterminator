extends Node

@export_enum("Quarter Chime", "Hour Strike", "Ringtone", "Minutes Bygone")
var debug_mode: int = 0

@onready var debug_mechanics: Array[Node] = [$"../QuarterChime", $"../HourStrike", $"../Ringtone2", $"../QuarterChime"]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		var mechanic: Node = debug_mechanics[debug_mode]

		if mechanic.has_method("start_mechanic"):
			mechanic.call("start_mechanic")
			print("DEBUG: ", mechanic.name)
			get_viewport().set_input_as_handled()

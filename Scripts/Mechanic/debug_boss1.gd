extends Node

@export_enum("Quarter Chime", "Hour Strike", "Ringtone", "Minutes Bygone", "Overclock", "Ringing Hour Strike", "Overclocked Quarter Chime", "Ravenous Midnight Chime", "Reversed Ravenous Midnight Chime")
var debug_mode: int = 0

@onready var battle_manager: Node = $"../BattleManager"
var debug_mechanics: Array[String] = ["QuarterChime", "HourStrike", "Ringtone", "MinutesBygone", "Overclock", "RingingHourStrike", "OverclockedQuarterChime", "RavenousMidnightChime", "ReversedRavenousMidnightChime"]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug") and not battle_manager.is_busy and not battle_manager.player.is_dead:
		battle_manager.is_busy = true
		get_viewport().set_input_as_handled()
		await battle_manager.play_mechanic(debug_mechanics[debug_mode])
		battle_manager.is_busy = false

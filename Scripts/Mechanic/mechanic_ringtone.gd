extends Node

@onready var ringtone: Node3D = $"../Ringtone"
@onready var area_3d: Area3D = $"../Ringtone/Area3D"

var cast_time: float = 4.0
var damage: float = 100.0
var is_in_range: bool

func _ready() -> void:
	area_3d.body_entered.connect(player_entered)
	area_3d.body_exited.connect(player_exited)

func start_mechanic() -> void:
	var roll = randi_range(1,2)
	match roll:
		1:
			print("Boss is casting RINGTONE")
			
		2:
			print("Boss is casting REVERSE RINGTONE")
	
	await get_tree().create_timer(cast_time).timeout
	
	resolve_mechanic(roll)

func resolve_mechanic(roll: int) -> void:
	match roll:
		1:
			if is_in_range:
				print("PLAYER TAKES DAMAGE")
		2:
			if not is_in_range:
				print("PLAYER TAKES DAMAGE!")



# EDITS BELOW



func player_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		is_in_range = true

func player_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		is_in_range = false

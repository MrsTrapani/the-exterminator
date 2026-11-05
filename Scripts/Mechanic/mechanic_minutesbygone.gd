extends Node

@onready var minute_hand: Node3D = $"../MinuteHand"
@onready var area_3d: Area3D = $"../MinuteHand/MeshInstance3D/Area3D"


var cast_time: float = 3.0
var damage: float = 50.0

var full_rotation_in: float = 20.0
var is_rotating: bool = false
var player_damaged: bool = false



func start_mechanic() -> void:
	print("Boss is casting MINUTES BYGONE")
	minute_hand.rotation_degrees.y = 0.0
	is_rotating = true




# EDITS BELOW




func _ready() -> void:
	area_3d.body_entered.connect(body_entered)

func _physics_process(delta: float) -> void:
	if is_rotating:
		minute_hand.rotation_degrees.y -= (360.0 / full_rotation_in) * delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_2"):
		speed_up_rotation()


func speed_up_rotation() -> void:
	full_rotation_in = 12.0

func normal_rotation() -> void:
	full_rotation_in = 20.0

func body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not player_damaged:
		print("PLAYER TAKES DAMAGE!")
		player_damaged = true
		await get_tree().create_timer(1.0).timeout
		player_damaged = false

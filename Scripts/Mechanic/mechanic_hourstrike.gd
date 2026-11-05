extends Node

@onready var time: Node3D = $"../QuarterlyChime"

@onready var _1: Sprite3D = $"../QuarterlyChime/1"
@onready var _2: Sprite3D = $"../QuarterlyChime/2"
@onready var _3: Sprite3D = $"../QuarterlyChime/3"
@onready var _4: Sprite3D = $"../QuarterlyChime/4"
@onready var _5: Sprite3D = $"../QuarterlyChime/5"
@onready var _6: Sprite3D = $"../QuarterlyChime/6"
@onready var _7: Sprite3D = $"../QuarterlyChime/7"
@onready var _8: Sprite3D = $"../QuarterlyChime/8"
@onready var _9: Sprite3D = $"../QuarterlyChime/9"
@onready var _10: Sprite3D = $"../QuarterlyChime/10"
@onready var _11: Sprite3D = $"../QuarterlyChime/11"
@onready var _12: Sprite3D = $"../QuarterlyChime/12"
@onready var all_numbers: Array[Sprite3D] = [_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12]

@onready var hour_hand: Node3D = $"../HourHand"


var rotation_step: int = 30
var rotation_start: int = 15

var cast_time: float = 5.0
var damage: float = 200.0

func start_mechanic() -> void:
	print("Boss is casting HOUR STRIKE")
	await scale_time()
	
	disable_collision()
	roll_number()
	hour_hand.show()
	
	await get_tree().create_timer(cast_time).timeout
	resolve_mechanic()


func resolve_mechanic() -> void:
	for number in all_numbers:
		var danger_zone: Area3D = number.get_node("DangerZone")
		var collision: CollisionShape3D = danger_zone.get_node("CollisionShape3D")

		if collision.disabled:
			continue

		for body in danger_zone.get_overlapping_bodies():
			if body.is_in_group("player"):
				print("PLAYER TAKES DAMAGE!")
				# Apply damage here
				break

	for number in all_numbers:
		number.get_node("DangerZone/CollisionShape3D").set_deferred("disabled", true)

	time.hide()
	hour_hand.hide()





# EDITS BELOW






func roll_number() -> void:
	var roll = randi_range(1,8)
	hour_hand.rotation_degrees.y = -rotation_start - (rotation_step * (roll - 1))
	define_danger_zone(roll)

func scale_time() -> void:
	var tween := create_tween()
	tween.tween_property(time, "scale", Vector3.ONE, 2)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	await tween.finished

func disable_collision() -> void:
	for number in all_numbers:
		number.get_node("DangerZone/CollisionShape3D").set_deferred("disabled", true)

func define_danger_zone(roll: int) -> void:
	for number in all_numbers.slice(0, roll):
		number.get_node("DangerZone/CollisionShape3D").set_deferred("disabled", false)

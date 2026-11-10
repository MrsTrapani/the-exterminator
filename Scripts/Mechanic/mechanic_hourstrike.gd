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
var rotation_start: int = 0

var cast_time: float = 2.0
var combo_cast_time: float = 8.0
var hour_step_interval: float = 1.0
var damage: float = 200.0
var is_running: bool = false
var cancelled: bool = false
var rolled_hour: int = 1
@onready var ringtone: Node = $"../Ringtone2"
@onready var quarter_chime: Node = $"../QuarterChime"

func start_mechanic(is_hard_mode: bool = false, ring_roll: int = 0) -> void:
	if is_running:
		return
	is_running = true
	cancelled = false
	if ring_roll == 0:
		ring_roll = randi_range(1, 2)
	print("Boss is casting HOUR STRIKE")
	disable_collision()
	quarter_chime.reset_colour()
	time.rotation_degrees.y = 0.0
	hour_hand.hide()
	time.scale = Vector3.ONE * 0.01
	time.show()
	await scale_time()
	if cancelled:
		return
	
	hour_hand.show()
	await roll_number()
	if cancelled:
		return
	
	var cast_name := "Hour Strike"
	if is_hard_mode:
		cast_name = "Ringing Hour Strike" if ring_roll == 1 else "Reversed Ringing Hour Strike"
	var duration := combo_cast_time if is_hard_mode else cast_time
	SignalHub.boss_cast_started.emit(cast_name, duration)
	await get_tree().create_timer(duration, false).timeout
	if cancelled:
		return
	quarter_chime.show_hour_warning(rolled_hour)
	if is_hard_mode:
		ringtone.show_warning(ring_roll)
	await get_tree().create_timer(0.5, false).timeout
	if cancelled:
		return
	resolve_mechanic()
	if is_hard_mode:
		ringtone.resolve_mechanic(ring_roll)
	is_running = false


func resolve_mechanic() -> void:
	quarter_chime.play_explosions()
	var damaged_players: Array[Node3D] = []
	for number in all_numbers:
		var danger_zone: Area3D = number.get_node("DangerZone")
		var collision: CollisionShape3D = danger_zone.get_node("CollisionShape3D")
		
		if collision.disabled:
			continue
			
		for body in danger_zone.get_overlapping_bodies():
			if body.is_in_group("player"):
				if not body in damaged_players:
					body.take_damage(damage)
					damaged_players.append(body)
				break
				
	for number in all_numbers:
		number.get_node("DangerZone/CollisionShape3D").set_deferred("disabled", true)

	time.hide()
	hour_hand.hide()





#EDITS BELOW






func roll_number() -> void:
	var roll = randi_range(3,8)
	rolled_hour = roll
	await advance_to_hour(roll)
	if not cancelled:
		define_danger_zone(roll)

func advance_to_hour(target_hour: int) -> void:
	for hour in range(1, target_hour + 1):
		if cancelled:
			return
		hour_hand.rotation_degrees.y = -rotation_start - (rotation_step * (hour - 1))
		if hour < target_hour:
			await get_tree().create_timer(hour_step_interval, false).timeout

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

func stop_mechanic() -> void:
	cancelled = true
	is_running = false
	disable_collision()
	time.hide()
	hour_hand.hide()

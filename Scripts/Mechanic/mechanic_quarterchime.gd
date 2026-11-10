extends Node

@export var bad_color: Color = Color("ae2c00")
@export var normal_color: Color = Color("f4a15e")

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

var cast_time: float = 6.0
var combo_cast_time: float = 8.0
var damage: float = 200.0
var is_running: bool = false
var cancelled: bool = false
var explosions: Array[Node3D] = []
var explosion_transforms: Array[Transform3D] = []

@onready var hour_strike: Node = $"../HourStrike"
@onready var minutes_bygone: Node = $"../MinutesBygone"
@onready var ringtone: Node = $"../Ringtone2"
@onready var boss: Node3D = $"../Boss1"

func start_mechanic(is_hard_mode: bool = false, is_midnight: bool = false, variant: int = -1, ring_roll: int = 0) -> void:
	if is_running:
		return
	is_running = true
	cancelled = false
	boss.can_rotate = false
	time.scale = Vector3.ONE * 0.01
	reset_colour()
	hour_strike.disable_collision()
	hour_strike.hour_hand.hide()
	if is_midnight:
		time.rotation_degrees.y = 0.0
	else:
		rotate_numbers()
	time.show()
	await scale_time()
	if cancelled:
		return

	var cast_name := "Quarter Chime"
	if is_midnight:
		if variant < 0:
			variant = randi_range(0, 2)
		if ring_roll == 0:
			ring_roll = randi_range(1, 2)
		var hours := [6, 3, 8]
		
		set_midnight_pattern(variant)
		hour_strike.cancelled = false
		hour_strike.hour_hand.show()
		await hour_strike.advance_to_hour(hours[variant])
		if cancelled:
			return
		cast_name = "Ravenous Midnight Chime" if ring_roll == 1 else "Reversed Ravenous Midnight Chime"
	else:
		roll_safe_quadrant()
		if is_hard_mode:
			cast_name = "Overclocked Quarter Chime"

	if is_hard_mode or is_midnight:
		minutes_bygone.speed_up_rotation()
	var duration := combo_cast_time if is_hard_mode or is_midnight else cast_time
	SignalHub.boss_cast_started.emit(cast_name, duration)
	await get_tree().create_timer(duration, false).timeout
	if cancelled:
		return
	show_quarter_warning()
	if is_midnight:
		ringtone.show_warning(ring_roll)
	await get_tree().create_timer(0.5, false).timeout
	if cancelled:
		return
	resolve_mechanic()
	if is_midnight:
		ringtone.resolve_mechanic(ring_roll)
	boss.can_rotate = true
	is_running = false

func resolve_mechanic() -> void:
	play_explosions()
	var damaged_players: Array[Node3D] = []
	for number in all_numbers:
		var danger_zone: Area3D = number.get_node("DangerZone")
		var collision: CollisionShape3D = danger_zone.get_node("CollisionShape3D")
		if collision.disabled:
			continue
		for body in danger_zone.get_overlapping_bodies():
			if body.is_in_group("player") and not body in damaged_players:
				body.take_damage(damage)
				damaged_players.append(body)
	hour_strike.disable_collision()
	time.hide()
	hour_strike.hour_hand.hide()





#EDITS BELOW









func _ready() -> void:
	for number in all_numbers:
		var explosion: Node3D = number.get_node("VFXExplosion")
		explosions.append(explosion)
		explosion_transforms.append(time.global_transform.affine_inverse() * explosion.global_transform)
	time.hide()
	time.scale = Vector3.ONE * 0.01
	hour_strike.hour_hand.hide()
	reset_colour()

func play_explosions() -> void:
	for i in range(all_numbers.size()):
		if all_numbers[i].get_node("DangerZone/CollisionShape3D").disabled:
			continue
		var explosion := explosions[i]
		var effect_transform := time.global_transform * explosion_transforms[i]
		if explosion.get_parent() != get_parent():
			explosion.reparent(get_parent())
		explosion.global_transform = effect_transform
		explosion.play_effect()

func reset_colour() -> void:
	for number in all_numbers:
		number.modulate = bad_color
		number.get_node("DangerPizza").hide()

func show_hour_warning(roll: int) -> void:
	for i in range(all_numbers.size()):
		all_numbers[i].get_node("DangerPizza").visible = i < roll

func show_quarter_warning() -> void:
	for number in all_numbers:
		number.get_node("DangerPizza").visible = number.modulate != normal_color

func enable_collision() -> void:
	for number in all_numbers:
		number.get_node("DangerZone/CollisionShape3D").set_deferred("disabled", false)

func rotate_numbers() -> void:
	time.rotation_degrees.y = randi_range(0, 11) * 30.0

func roll_safe_quadrant() -> void:
	var first_number := randi_range(0, 3) * 3
	enable_collision()
	for i in range(first_number, first_number + 3):
		all_numbers[i].modulate = normal_color
		all_numbers[i].get_node("DangerZone/CollisionShape3D").set_deferred("disabled", true)

func set_midnight_pattern(variant: int) -> void:
	var safe_patterns := [[11, 12, 1], [3, 4, 5], [7, 8, 9]]
	var hours := [6, 3, 8]
	reset_colour()
	for i in range(12):
		var number := i + 1
		var is_quarter_safe: bool = number in safe_patterns[variant]
		var is_safe: bool = is_quarter_safe and number > hours[variant]
		all_numbers[i].modulate = normal_color if is_quarter_safe else bad_color
		all_numbers[i].get_node("DangerZone/CollisionShape3D").set_deferred("disabled", is_safe)

func scale_time() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(time, "scale", Vector3.ONE, 2.0)
	await tween.finished

func stop_mechanic() -> void:
	cancelled = true
	for explosion in explosions:
		explosion.stop_effect()
	is_running = false
	boss.can_rotate = true
	hour_strike.disable_collision()
	time.hide()
	hour_strike.hour_hand.hide()

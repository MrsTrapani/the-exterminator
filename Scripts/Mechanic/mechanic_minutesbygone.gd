extends Node

@onready var minute_hand: Node3D = $"../MinuteHand"
@onready var area_3d: Area3D = $"../MinuteHand/MeshInstance3D/Area3D"

var cast_time: float = 3.0
var damage: float = 50.0
var full_rotation_in: float = 20.0
var overclock_duration: float = 20.0
var overclock_remaining: float = 0.0
var hit_cooldown: float = 0.0
var is_rotating: bool = false
var is_running: bool = false
var cancelled: bool = false

func start_mechanic(is_hard_mode: bool = false) -> void:
	if is_running:
		return
	is_running = true
	cancelled = false
	var cast_name := "Overclock" if is_hard_mode else "Minutes Bygone"
	SignalHub.boss_cast_started.emit(cast_name, cast_time)
	await get_tree().create_timer(cast_time, false).timeout
	if cancelled:
		return
	if is_hard_mode:
		speed_up_rotation()
	else:
		minute_hand.rotation_degrees.y = 0.0
		is_rotating = true
		minute_hand.show()
	is_running = false

func _ready() -> void:
	minute_hand.hide()

func _physics_process(delta: float) -> void:
	if overclock_remaining > 0.0:
		overclock_remaining = maxf(0.0, overclock_remaining - delta)
		if overclock_remaining == 0.0:
			normal_rotation()
	if not is_rotating:
		return
	minute_hand.rotation_degrees.y -= (360.0 / full_rotation_in) * delta
	hit_cooldown = maxf(0.0, hit_cooldown - delta)
	if hit_cooldown == 0.0:
		for body in area_3d.get_overlapping_bodies():
			if body.is_in_group("player"):
				body.take_damage(damage)
				hit_cooldown = 1.0
				break

func speed_up_rotation() -> void:
	full_rotation_in = 12.0
	overclock_remaining = overclock_duration
	is_rotating = true
	minute_hand.show()

func normal_rotation() -> void:
	full_rotation_in = 20.0
	overclock_remaining = 0.0

func stop_mechanic() -> void:
	cancelled = true
	is_running = false
	is_rotating = false
	normal_rotation()
	minute_hand.hide()

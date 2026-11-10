extends Node

@onready var ringtone: Node3D = $"../Ringtone"
@onready var area_3d: Area3D = $"../Ringtone/Area3D"
@onready var ring_explosion: Node3D = $"../Ringtone/VFXImpact_Ring"
@onready var torus_explosion: Node3D = $"../Ringtone/VFXImpact_Torus"
@onready var danger_ring: MeshInstance3D = $"../Ringtone/Boss1DangerRing"
@onready var danger_torus: MeshInstance3D = $"../Ringtone/Boss1DangerTorus"

var cast_time: float = 4.0
var damage: float = 100.0
var is_running: bool = false
var cancelled: bool = false

func _ready() -> void:
	hide_warning()

func show_warning(roll: int) -> void:
	danger_ring.visible = roll == 1
	danger_torus.visible = roll == 2

func hide_warning() -> void:
	danger_ring.hide()
	danger_torus.hide()

func start_mechanic(roll: int = 0) -> void:
	if is_running:
		return
	is_running = true
	cancelled = false
	if roll == 0:
		roll = randi_range(1, 2)
	var cast_name := "Ringtone" if roll == 1 else "Reverse Ringtone"
	SignalHub.boss_cast_started.emit(cast_name, cast_time)
	await get_tree().create_timer(cast_time, false).timeout
	if cancelled:
		return
	show_warning(roll)
	await get_tree().create_timer(0.5, false).timeout
	if cancelled:
		return
	resolve_mechanic(roll)
	is_running = false

func resolve_mechanic(roll: int) -> void:
	hide_warning()
	ring_explosion.stop_effect()
	torus_explosion.stop_effect()
	if roll == 1:
		ring_explosion.play_effect()
	else:
		torus_explosion.play_effect()
	for player in get_tree().get_nodes_in_group("player"):
		var is_in_range: bool = area_3d.overlaps_body(player)
		if (roll == 1 and is_in_range) or (roll == 2 and not is_in_range):
			player.take_damage(damage)

func stop_mechanic() -> void:
	hide_warning()
	cancelled = true
	is_running = false
	ring_explosion.stop_effect()
	torus_explosion.stop_effect()

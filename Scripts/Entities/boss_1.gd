extends CharacterBody3D

signal health_changed
signal died

@export var max_health: float = 20000.0
var current_health: float
var is_dead: bool = false
var damage_flash_remaining: float = 0.0
var normal_modulate: Color

@onready var rotation_indicator: Sprite3D = $RotationIndicator
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D


var is_selected: bool = false
var can_be_selected: bool = false
var player: Node3D
var can_rotate: bool = true

func _ready() -> void:
	current_health = max_health
	normal_modulate = animated_sprite_3d.modulate
	rotation_indicator.hide()
	animated_sprite_3d.play("idle")
	SignalHub.boss_cast_started.connect(play_cast_anim)


func _process(delta: float) -> void:
	if damage_flash_remaining > 0.0:
		damage_flash_remaining = maxf(0.0, damage_flash_remaining - delta)
		if damage_flash_remaining == 0.0:
			animated_sprite_3d.modulate = normal_modulate
	
	if not can_rotate:
		return
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node3D
	if not is_instance_valid(player):
		return

	var direction := player.global_position - global_position
	direction.y = 0.0
	if not direction.is_zero_approx():
		#arrow rotata
		rotation_indicator.global_rotation.y = atan2(direction.x, direction.z)


func _on_selection_zone_mouse_entered() -> void:
	can_be_selected = true


func _on_selection_zone_mouse_exited() -> void:
	can_be_selected = false


func _input(event: InputEvent) -> void:
	if is_dead or get_tree().root.has_node("BattleFade"):
		return
	if event.is_action_pressed("lmb") and can_be_selected:
		if is_selected:
			rotation_indicator.hide()
			is_selected = false
			print("boss selected")
			return
		else:
			rotation_indicator.show()
			is_selected = true
			print("boss unselected")
			return

func play_cast_anim(_cast_name: String, duration: float) -> void:
	if is_dead:
		return
	animated_sprite_3d.play("cast")
	await get_tree().create_timer(duration, false).timeout
	animated_sprite_3d.play("idle")

func take_damage(amount: float) -> void:
	if is_dead or amount <= 0.0:
		return
	current_health = maxf(0.0, current_health - amount)
	animated_sprite_3d.modulate = Color(1.0, 0.2, 0.2, normal_modulate.a)
	damage_flash_remaining = 0.2
	health_changed.emit()
	if current_health == 0.0:
		is_dead = true
		is_selected = false
		can_rotate = false
		rotation_indicator.hide()
		died.emit()
